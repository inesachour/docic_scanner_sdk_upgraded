import 'dart:typed_data';
import 'package:flutter/material.dart';

class ScanResultScreen extends StatefulWidget {
  List<Uint8List> images;

  ScanResultScreen({super.key, required this.images});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemBuilder: (BuildContext context, int index){
            return Column(
              children: [
                Image.memory(widget.images[index]),
                Text("Page ${index+1}"),
                SizedBox(height: 20,),
              ],
            );
            },
        itemCount: widget.images.length,
      ),
    );
  }
}
