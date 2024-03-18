import 'package:document_scanner_ocr/src/camera_screen.dart';
import 'package:flutter/material.dart';

class DocumentScannerOcr extends StatefulWidget {
  const DocumentScannerOcr({super.key});

  @override
  State<DocumentScannerOcr> createState() => _DocumentScannerOcrState();
}

class _DocumentScannerOcrState extends State<DocumentScannerOcr> {
  @override
  Widget build(BuildContext context) {
    return CameraScreen();
  }
}
