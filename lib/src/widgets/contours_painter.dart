import 'package:document_scanner_ocr/src/docic_mobile_sdk.dart';
import 'package:flutter/material.dart';

class ContoursPainter extends CustomPainter {
  final DetectedCorners detectedCorners;

  ContoursPainter({required this.detectedCorners});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    path.moveTo(detectedCorners.topLeft.dx, detectedCorners.topLeft.dy);
    path.lineTo(detectedCorners.topRight.dx, detectedCorners.topRight.dy);
    path.lineTo(detectedCorners.bottomRight.dx, detectedCorners.bottomRight.dy);
    path.lineTo(detectedCorners.bottomLeft.dx, detectedCorners.bottomLeft.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
