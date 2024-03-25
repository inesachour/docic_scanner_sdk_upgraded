import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  bool _isLoading = false;

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
              Image.file(
                File(widget.images[_currentImageIndex].path),
                fit: BoxFit.fitHeight,
              ),
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
