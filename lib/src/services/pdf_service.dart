import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class PdfService{
  static pw.Document generatePdfFile(List<Uint8List> images){
    final pdf = pw.Document();
    images.forEach((image) {
      pdf.addPage(
          pw.Page(build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pw.MemoryImage(image), fit: pw.BoxFit.contain,),
            );
          }),
      );
    });
    return pdf;
  }
}