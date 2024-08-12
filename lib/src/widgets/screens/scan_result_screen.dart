import 'dart:typed_data';
import 'package:document_scanner_ocr/document_scanner_ocr.dart';
import 'package:document_scanner_ocr/src/services/pdf_service.dart';
import 'package:document_scanner_ocr/src/utils/scanned_images_manager.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

class ScanResultScreen extends StatefulWidget {
  Function(ScannerResult) onFinish;

  ScanResultScreen({super.key, required this.onFinish});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {

  final scannedImages = ScannedImagesManager().imageBytes;

  TextStyle textStyle = const TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text("Annuler", style: textStyle,),
                    onTap: (){
                      scannedImages.clear();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),

                  GestureDetector(
                    child: Text("Ajouter", style: textStyle,),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),

                  GestureDetector(
                    child: Text("Confirmer", style: textStyle,),
                    onTap: () async {
                      pw.Document pdf = PdfService.generatePdfFile(scannedImages);
                      List<int> pdfBytes = await pdf.save();
                      widget.onFinish.call(
                          ScannerResult(
                            numberOfPages: scannedImages.length,
                            images: scannedImages,
                            pdfBytes: pdfBytes,
                          )
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 7,
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: Image.memory(scannedImages[index])),
                        Container(
                          child: Text("Page ${index+1}", style: textStyle, textAlign: TextAlign.center,),
                          color: Colors.black,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(9),
                        ),
                      ],
                    ),
                  );
                  },
              itemCount: scannedImages.length,
            ),
          ),
        ],
      ),
    );
  }
}