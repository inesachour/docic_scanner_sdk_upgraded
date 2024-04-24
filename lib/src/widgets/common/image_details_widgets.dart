import 'package:document_scanner_ocr/src/widgets/common/image_editing_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextStyle textStyle = const TextStyle(
    color: Colors.white, decoration: TextDecoration.none, fontSize: 14);

Widget ScanImageHeader(
    {required BuildContext context,
    required bool isLoading,
    required int imageNumber}) {
  return Container(
    color: Colors.black,
    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isLoading)
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Text(
              "Page $imageNumber",
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget ScanImageFromGalleryFooter(
    {required bool isLoading,
    required VoidCallback onNextButtonClick,
    required int imagesNumber,
    required bool isLastImage}) {
  return Container(
    color: Colors.black,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isLoading) ImageCropper(),
        if (!isLoading) ImageRotator(),
        if (!isLoading)
          GestureDetector(
            onTap: onNextButtonClick,
            child: Text(
              isLastImage ? "Confirmer\n($imagesNumber)" : "Suivant",
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ),
  );
}

Widget ScanImageFromCameraFooter({required VoidCallback onNextButtonClick}) {
  return Container(
    color: Colors.black,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ImageCropper(),
        ImageRotator(),
        GestureDetector(
          onTap: onNextButtonClick,
          child: Text(
            "Suivant",
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
