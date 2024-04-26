import 'dart:ffi' as ffi;
import 'dart:ui';
import 'package:ffi/ffi.dart';

final class Coordinate extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;

  factory Coordinate.allocate(double x, double y) => calloc<Coordinate>().ref
    ..x = x
    ..y = y;
}

final class NativeDetectedCorners extends ffi.Struct {
  external Coordinate topLeft;
  external Coordinate topRight;
  external Coordinate bottomLeft;
  external Coordinate bottomRight;

  factory NativeDetectedCorners.allocate(Coordinate topLeft,
          Coordinate topRight, Coordinate bottomLeft, Coordinate bottomRight) =>
      calloc<NativeDetectedCorners>().ref
        ..topLeft = topLeft
        ..topRight = topRight
        ..bottomLeft = bottomLeft
        ..bottomRight = bottomRight;
}

class DetectedCorners {
  DetectedCorners({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  Offset topLeft;
  Offset topRight;
  Offset bottomLeft;
  Offset bottomRight;

  bool isEmpty() {
    return topLeft == Offset.zero &&
        topRight == Offset.zero &&
        bottomLeft == Offset.zero &&
        bottomRight == Offset.zero;
  }
}

final class NativeScanFrameResult extends ffi.Struct {
  external NativeDetectedCorners corners;
  @ffi.Int32()
  external int outputBufferSize;

  factory NativeScanFrameResult.allocate(
          NativeDetectedCorners corners, int outputBufferSize) =>
      calloc<NativeScanFrameResult>().ref
        ..corners = corners
        ..outputBufferSize = outputBufferSize;
}

class ScanFrameResult {
  ScanFrameResult({
    required this.corners,
    required this.outputBufferSize,
  });

  DetectedCorners corners;
  int outputBufferSize;
}
