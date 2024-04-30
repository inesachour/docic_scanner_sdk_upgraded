import 'package:flutter/material.dart';

Widget ImageCropper({required VoidCallback cropImage}) {
  return GestureDetector(
    onTap: cropImage,
    child: const Icon(
      Icons.crop,
      color: Colors.white,
    ),
  );
}

Widget ImageRotator({required VoidCallback rotateImage}) {
  return GestureDetector(
    onTap: rotateImage,
    child: const Icon(
      Icons.rotate_right,
      color: Colors.white,
    ),
  );
}
