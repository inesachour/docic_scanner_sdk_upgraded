import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/src/docic_mobile_sdk.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

class ScanImageScreen extends StatefulWidget {
  List<XFile> images;
  bool isFromGallery;

  ScanImageScreen(
      {super.key, required this.images, this.isFromGallery = false});

  @override
  State<ScanImageScreen> createState() => _ScanImageScreenState();
}

class _ScanImageScreenState extends State<ScanImageScreen> {
  TextStyle textStyle = const TextStyle(
      color: Colors.white, decoration: TextDecoration.none, fontSize: 14);
  int _currentImageIndex = 0;
  bool _isLoading = true;
  late bool _isConfirm;
  Image? _currentScannedImage;
  late StreamSubscription sub;
  List<Image> processedImages = [];
  late int imagesNumber;

  Future<Image?> scanCurrentImage(XFile image) async {
    setState(() {
      _isLoading = true;
    });

    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn<ScanImageArguments>(scanCurrentImageIsolated, ScanImageArguments(image, receivePort.sendPort));
    sub = receivePort.listen((processedImage) async {
      setState(() {
        _currentScannedImage = processedImage;
        _isLoading = false;
        if(processedImage != null){
          processedImages.add(processedImage);
        }
      });
    });

    return _currentScannedImage;
  }

  @override
  void initState() {
    super.initState();
    imagesNumber = widget.isFromGallery ? widget.images.length : 0;
    _isConfirm = (imagesNumber - 1 == _currentImageIndex);
    scanCurrentImage(widget.images[0]);
  }

  @override
  void dispose() async {
    Future.delayed(Duration.zero, () async {
      await sub.cancel();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isLoading)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Page ${_currentImageIndex + 1}",
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _currentScannedImage == null
                  ? Image.file(
                      File(widget.images[_currentImageIndex].path),
                      fit: BoxFit.fitHeight,
                    )
                  : _currentScannedImage!,
              if (_isLoading)
                const Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      color: Color(0xff808080),
                      strokeWidth: 7,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_isLoading)
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.crop,
                      color: Colors.white,
                    ),
                  ),
                if (!_isLoading)
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.rotate_right,
                      color: Colors.white,
                    ),
                  ),
                if (!_isLoading)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if(_currentImageIndex < imagesNumber - 1){
                          _currentImageIndex++;
                          _currentScannedImage = null;
                          scanCurrentImage(widget.images[_currentImageIndex]);
                        }

                        if(_currentImageIndex == imagesNumber - 1){
                          _isConfirm = true;
                        }
                      });
                    },
                    child: Text(
                      _isConfirm ? "Confirmer\n($imagesNumber)" :"Suivant",
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

class ScanImageArguments {
  final XFile image;
  final SendPort sendPort;

  ScanImageArguments(this.image, this.sendPort);
}

void scanCurrentImageIsolated(ScanImageArguments args) {
  Pointer<Pointer<Uint8>> encodedOutputImage = malloc.allocate(8);
  int encodedImageLength = scanImage(args.image.path, encodedOutputImage);

  if (encodedImageLength == 0) {
    args.sendPort.send(null);
    return;
  }

  Pointer<Uint8> cppPointer = encodedOutputImage[0];
  Uint8List encodedImageBytes = cppPointer.asTypedList(encodedImageLength);

  malloc.free(cppPointer);
  malloc.free(encodedOutputImage);

  args.sendPort.send(Image.memory(encodedImageBytes, fit: BoxFit.fitHeight,));
}
