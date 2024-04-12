import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:ui';
import 'package:ffi/ffi.dart';

final class Coordinate extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;

  factory Coordinate.allocate(double x, double y) =>
      calloc<Coordinate>().ref
        ..x = x
        ..y = y;
}

final class NativeDetectedCorners extends ffi.Struct {
  external Coordinate topLeft;
  external Coordinate topRight;
  external Coordinate bottomLeft;
  external Coordinate bottomRight;

  factory NativeDetectedCorners.allocate(
      Coordinate topLeft,
      Coordinate topRight,
      Coordinate bottomLeft,
      Coordinate bottomRight) =>
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
}


// C function signatures
typedef _scan_image_func = ffi.Int32 Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);
typedef _scan_frame_func = NativeDetectedCorners Function(
    ffi.Pointer<ffi.Uint8> y, ffi.Pointer<ffi.Uint8> u, ffi.Pointer<ffi.Uint8> v, ffi.Int32 height, ffi.Int32 width);

// Dart function signatures
typedef _ScanImageFunc = int Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);
typedef _ScanFrameFunc = NativeDetectedCorners Function(
ffi.Pointer<ffi.Uint8> y, ffi.Pointer<ffi.Uint8> u, ffi.Pointer<ffi.Uint8> v, int height, int width);

// Getting the library
ffi.DynamicLibrary _lib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libdocic_mobile_sdk.so')
    : ffi.DynamicLibrary.process();

// Looking for the functions
final _ScanImageFunc _scanImage =
    _lib.lookupFunction<_scan_image_func, _ScanImageFunc>('scanFromImage');
final _ScanFrameFunc _scanFrame =
    _lib.lookupFunction<_scan_frame_func, _ScanFrameFunc>('scanFromLiveCamera');

int scanImage(String path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput) {
  return _scanImage(path.toNativeUtf8(), encodedOutput);
}

DetectedCorners scanFrame(ffi.Pointer<ffi.Uint8> y, ffi.Pointer<ffi.Uint8> u, ffi.Pointer<ffi.Uint8> v, int height, int width){
  NativeDetectedCorners nativeDetectedCorners = _scanFrame(y, u, v, height, width);
  return DetectedCorners(
    topLeft: Offset(nativeDetectedCorners.topLeft.x, nativeDetectedCorners.topLeft.y),
    topRight: Offset(nativeDetectedCorners.topRight.x, nativeDetectedCorners.topRight.y),
    bottomLeft: Offset(nativeDetectedCorners.bottomLeft.x, nativeDetectedCorners.bottomLeft.y),
    bottomRight: Offset(nativeDetectedCorners.bottomRight.x, nativeDetectedCorners.bottomRight.y),
  );
}