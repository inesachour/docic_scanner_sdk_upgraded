import 'dart:io';

import 'package:flutter/material.dart';
import 'package:document_scanner_ocr/document_scanner_ocr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: ScannerOcrScreen(),
    );
  }
}

class ScannerOcrScreen extends StatefulWidget {
  const ScannerOcrScreen({super.key});

  @override
  State<ScannerOcrScreen> createState() => _ScannerOcrScreenState();
}

class _ScannerOcrScreenState extends State<ScannerOcrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DocumentScannerOcr(
        onFinish: (ScannerResult scannerResult) async{
          String directory = "/storage/emulated/0/Download/";
          bool dirDownloadExists = await Directory(directory).exists();
          if (dirDownloadExists) {
            directory = "/storage/emulated/0/Download";
          } else {
            directory = "/storage/emulated/0/Downloads";
          }
          final file = File("$directory/testWOW.pdf");
          await file.writeAsBytes(scannerResult.pdfBytes);
        },
      ),
    );
  }
}
