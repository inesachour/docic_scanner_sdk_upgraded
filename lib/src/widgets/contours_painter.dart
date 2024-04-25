import 'dart:ui' as ui;
import 'package:document_scanner_ocr/src/widgets/models/scan_models.dart';
import 'package:flutter/material.dart';

class ContoursPainter extends CustomPainter {
  final DetectedCorners detectedCorners;
  int imageHeight;
  int imageWidth;
  double cameraWidthFactor;
  Color color;

  ContoursPainter(
      {required this.detectedCorners,
      required this.imageHeight,
      required this.imageWidth,
      required this.cameraWidthFactor,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double top = 0.0;
    double left = 0.0;

    double renderedImageHeight = size.height;
    double renderedImageWidth = size.width;

    double heightFactor = size.height / imageHeight;
    double widthFactor = size.width / imageWidth;

    renderedImageHeight = imageHeight * heightFactor;
    top = ((size.height - renderedImageHeight) / 2);

    renderedImageWidth = imageWidth * widthFactor * cameraWidthFactor;
    left = ((size.width - renderedImageWidth) / 2);

    final points = [
      Offset(left + detectedCorners.topLeft.dx * renderedImageWidth,
          top + detectedCorners.topLeft.dy * renderedImageHeight),
      Offset(left + detectedCorners.topRight.dx * renderedImageWidth,
          top + detectedCorners.topRight.dy * renderedImageHeight),
      Offset(left + detectedCorners.bottomRight.dx * renderedImageWidth,
          top + (detectedCorners.bottomRight.dy * renderedImageHeight)),
      Offset(left + detectedCorners.bottomLeft.dx * renderedImageWidth,
          top + detectedCorners.bottomLeft.dy * renderedImageHeight),
      Offset(left + detectedCorners.topLeft.dx * renderedImageWidth,
          top + detectedCorners.topLeft.dy * renderedImageHeight),
    ];

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(ui.PointMode.polygon, points, paint);

    for (Offset point in points) {
      canvas.drawCircle(point, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
