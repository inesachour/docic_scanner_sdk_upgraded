import 'dart:typed_data';

import 'package:flutter/material.dart';

class TestingWidget extends StatefulWidget {
  TestingWidget({super.key, required this.bytes});
  Uint8List bytes;

  @override
  State<TestingWidget> createState() => _TestingWidgetState();
}

class _TestingWidgetState extends State<TestingWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.memory(widget.bytes),
      ),
    );
  }
}
