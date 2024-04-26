import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/document_scanner_ocr.dart';
import 'package:document_scanner_ocr/src/docic_mobile_sdk.dart';
import 'package:document_scanner_ocr/src/widgets/common/image_details_widgets.dart';
import 'package:document_scanner_ocr/src/widgets/screens/scan_result_screen.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

class ScanImageFromGalleryScreen extends StatefulWidget {
  List<XFile> images;
  Function(ScannerResult) onFinish;

  ScanImageFromGalleryScreen({super.key, required this.images, required this.onFinish});

  @override
  State<ScanImageFromGalleryScreen> createState() => _ScanImageFromGalleryScreenState();
}

class _ScanImageFromGalleryScreenState
    extends State<ScanImageFromGalleryScreen> {
  TextStyle textStyle = const TextStyle(
      color: Colors.white, decoration: TextDecoration.none, fontSize: 14);

  late bool _isLastImage;
  late StreamSubscription sub; // Subscription for the isolate port
  late int imagesNumber;

  int _currentImageIndex = 0;
  bool _isLoading = true;
  List<Uint8List> processedImages = [];

  Future<void> scanCurrentImage(XFile image) async {
    setState(() {
      _isLoading = true;
    });

    // Create a receive port from which the main isolate will receive messages from the created isolate
    final ReceivePort receivePort = ReceivePort();

    // Create an isolate to process the image in an isolated environment
    await Isolate.spawn<ScanImageArguments>(scanCurrentImageIsolated, ScanImageArguments(image, receivePort.sendPort));

    // Listen for the returned result from the created isolate
    sub = receivePort.listen((processedImageBytes) async {
      _isLoading = false;

      if (processedImageBytes == null) {
        processedImageBytes = await widget.images[_currentImageIndex].readAsBytes();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Aucun document n'a été détecté"),
          backgroundColor: Color(0xffff0f0f),
          elevation: 10.0,
        ));
      }

      processedImages.add(processedImageBytes);
      setState(() {});
    });
  }

  void onNextButtonClick() async {
    _currentImageIndex++;

    if (_currentImageIndex < imagesNumber - 1) {
      scanCurrentImage(widget.images[_currentImageIndex]);
      setState(() {});
    }
    else if (_currentImageIndex == imagesNumber - 1) {
      _isLastImage = true;
      scanCurrentImage(widget.images[_currentImageIndex]);
      setState(() {});
    }
    else {
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  ScanResultScreen(
                    images: processedImages,
                    onFinish: widget.onFinish,
                  )
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    imagesNumber = widget.images.length;
    _isLastImage = (imagesNumber - 1 == _currentImageIndex);
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ScanImageHeader(
              context: context,
              isLoading: _isLoading,
              imageNumber: _currentImageIndex + 1,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _currentImageIndex >= processedImages.length
                      ? Image.file(
                          File(widget.images[_currentImageIndex].path),
                          fit: BoxFit.fitHeight,
                        )
                      : Image.memory(
                          processedImages[_currentImageIndex],
                          fit: BoxFit.fitHeight,
                        ),
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
          ),
          Expanded(
            child: ScanImageFromGalleryFooter(
              isLoading: _isLoading,
              onNextButtonClick: onNextButtonClick,
              imagesNumber: imagesNumber,
              isLastImage: _isLastImage,
            ),
          ),
        ],
      ),
    );
  }
}

class ScanImageArguments {
  final XFile image;
  final SendPort sendPort;

  ScanImageArguments(this.image, this.sendPort);
}

// Function that will be executing in the created isolate
void scanCurrentImageIsolated(ScanImageArguments args) {
  // Allocate memory for the encoded output image
  Pointer<Pointer<Uint8>> encodedOutputImage = malloc.allocate(8);

  // Call the C++ function to scan the image and obtain the length of the encoded image
  int encodedImageLength = scanImage(args.image.path, encodedOutputImage);

  if (encodedImageLength == 0) {
    args.sendPort.send(null);
    return;
  }

  // Retrieve the pointer to the encoded image
  Pointer<Uint8> cppPointer = encodedOutputImage[0];
  Uint8List encodedImageBytes = cppPointer.asTypedList(encodedImageLength);

  malloc.free(cppPointer);
  malloc.free(encodedOutputImage);

  // Send the encoded image bytes to the send port
  args.sendPort.send(encodedImageBytes);
}
