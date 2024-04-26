import 'dart:typed_data';

class ScannerResult {
  ScannerResult(
      {required this.numberOfPages,
      required this.images,
      required this.pdfBytes});
  int numberOfPages;
  List<Uint8List> images;
  String pdfBytes;
}
