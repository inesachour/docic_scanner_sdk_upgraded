import 'dart:typed_data';
import 'package:document_scanner_ocr/document_scanner_ocr.dart';
import 'package:document_scanner_ocr/src/services/image_editing_service.dart';
import 'package:document_scanner_ocr/src/utils/scanned_images_manager.dart';
import 'package:document_scanner_ocr/src/widgets/common/image_details_widgets.dart';
import 'package:document_scanner_ocr/src/widgets/screens/scan_result_screen.dart';
import 'package:flutter/material.dart';

class ScanImageFromCameraScreen extends StatefulWidget {
  Uint8List processedImage;
  Function(ScannerResult) onFinish;

  ScanImageFromCameraScreen({super.key, required this.processedImage, required this.onFinish});

  @override
  State<ScanImageFromCameraScreen> createState() => _ScanImageFromCameraScreenState();
}

class _ScanImageFromCameraScreenState extends State<ScanImageFromCameraScreen> {

  final scannedImages = ScannedImagesManager().imageBytes;

  void onNextButtonClick() async {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                ScanResultScreen(
                  onFinish: widget.onFinish,
                )
        ));
  }

  void cropImage() async {
    Uint8List? result = await ImageEditingService.cropImage(scannedImages[scannedImages.length - 1]);
    if(result != null){
      setState(() {
        scannedImages[scannedImages.length - 1] = result;
      });
    }
  }

  void rotateImage() async {
    Uint8List? result = await ImageEditingService.rotateImage(scannedImages[scannedImages.length - 1]);
    if(result != null){
      setState(() {
        scannedImages[scannedImages.length - 1] = result;
      });
    }
  }

  @override
  void initState() {
    scannedImages.add(widget.processedImage);
    super.initState();
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
              imageNumber: scannedImages.length,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black,
              child: Image.memory(scannedImages[scannedImages.length - 1]),
            ),
          ),
          Expanded(
            child: ScanImageFromCameraFooter(
              onNextButtonClick: onNextButtonClick,
              cropImage: cropImage,
              rotateImage: rotateImage
            ),
          ),
        ],
      ),
    );
  }
}
