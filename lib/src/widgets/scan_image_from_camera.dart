import 'dart:typed_data';

import 'package:document_scanner_ocr/src/widgets/add_page_popup.dart';
import 'package:document_scanner_ocr/src/widgets/common/image_details_widgets.dart';
import 'package:flutter/material.dart';

class ScanImageFromCameraScreen extends StatefulWidget {
  ScanImageFromCameraScreen(
      {super.key, required this.image, required this.imageIndex});
  Uint8List image;
  int imageIndex;

  @override
  State<ScanImageFromCameraScreen> createState() =>
      _ScanImageFromCameraScreenState();
}

class _ScanImageFromCameraScreenState extends State<ScanImageFromCameraScreen> {
  void onNextButtonClick() async {
    final bool addAnotherImage = await showDialog(
      context: context,
      builder: (BuildContext context) => const AddPagePopup(),
    );
    if (addAnotherImage) {
      Navigator.pop(context, true);
    } else {
      //TODO GENERATE PDF OR LIST LIST OF IMAGES
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ScanImageHeader(
              context: context,
              isLoading: false,
              imageNumber: widget.imageIndex + 1,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black,
              child: Image.memory(widget.image),
            ),
          ),
          Expanded(
            child: ScanImageFromCameraFooter(
              onNextButtonClick: onNextButtonClick,
            ),
          ),
        ],
      ),
    );
  }
}
