import 'dart:typed_data';

import 'package:flutter/material.dart';

class ScanImageFromCameraScreen extends StatefulWidget {
  ScanImageFromCameraScreen({super.key, required this.image, required this.imageNumber});
  Uint8List image;
  int imageNumber;

  @override
  State<ScanImageFromCameraScreen> createState() => _ScanImageFromCameraScreenState();
}

class _ScanImageFromCameraScreenState extends State<ScanImageFromCameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}
