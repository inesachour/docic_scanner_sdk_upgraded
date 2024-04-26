import 'dart:typed_data';
import 'package:document_scanner_ocr/src/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ScanResultScreen extends StatefulWidget {
  List<Uint8List> images;

  ScanResultScreen({super.key, required this.images});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {

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
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Text("Confirmer", style: textStyle,),
                    onTap: (){
                      pw.Document pdf = PdfService.generatePdfFile(widget.images);
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
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: Image.memory(widget.images[index])),
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
              itemCount: widget.images.length,
            ),
          ),
        ],
      ),
    );
  }
}
