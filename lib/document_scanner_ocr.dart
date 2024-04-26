import 'package:document_scanner_ocr/src/models/scanner_result_model.dart';
import 'package:document_scanner_ocr/src/widgets/screens/camera_screen.dart';
import 'package:flutter/material.dart';

export 'src/models/scanner_result_model.dart';

class DocumentScannerOcr extends StatefulWidget {
  Function(ScannerResult) onFinish;

  DocumentScannerOcr({super.key, required this.onFinish});

  @override
  State<DocumentScannerOcr> createState() => _DocumentScannerOcrState();
}

class _DocumentScannerOcrState extends State<DocumentScannerOcr> {
  @override
  Widget build(BuildContext context) {
    return CameraScreen(onFinish: widget.onFinish,);
  }
}
