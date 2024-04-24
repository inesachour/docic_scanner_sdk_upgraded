import 'dart:typed_data';

import 'package:flutter/material.dart';

class ScanImageFromCameraScreen extends StatefulWidget {
  ScanImageFromCameraScreen({super.key, required this.image});
  Uint8List image;

  @override
  State<ScanImageFromCameraScreen> createState() => _ScanImageFromCameraScreenState();
}

class _ScanImageFromCameraScreenState extends State<ScanImageFromCameraScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}
