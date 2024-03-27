import 'dart:ffi';
import 'dart:io';
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
  Image? _currentScannedImage;

  Image? scanCurrentImage(XFile image) {
    setState(() {
      _isLoading = true;
    });

    Pointer<Pointer<Uint8>> encodedOutputImage = malloc.allocate(8);
    int encodedImageLength = scanImage(image.path, encodedOutputImage);

    setState(() {
      _isLoading = false;
    });

    if (encodedImageLength == 0) {
      return null;
    }

    Pointer<Uint8> cppPointer = encodedOutputImage[0];
    Uint8List encodedImageBytes = cppPointer.asTypedList(encodedImageLength);

    malloc.free(cppPointer);
    malloc.free(encodedOutputImage);

    setState(() {
      _currentScannedImage = Image.memory(encodedImageBytes, fit: BoxFit.fitHeight,);
    });

    return _currentScannedImage;
  }

  @override
  void initState() {
    super.initState();
    Image? image = scanCurrentImage(widget.images[0]);
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
                    onTap: () {},
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
                      color: Colors.grey,
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
                        if (widget.images.length - 1 > _currentImageIndex) {
                          _currentImageIndex++;
                          _currentScannedImage = null;
                        } else {
                          if (widget.isFromGallery) {
                            //TODO show pop to add more images or not
                          }
                          //TODO return processed image(s)
                        }
                      });
                    },
                    child: Text(
                      "Suivant",
                      style: textStyle,
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
