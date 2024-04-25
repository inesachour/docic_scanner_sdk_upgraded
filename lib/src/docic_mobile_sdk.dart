import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:ui';
import 'package:document_scanner_ocr/src/widgets/models/scan_models.dart';
import 'package:ffi/ffi.dart';

// C function signatures
typedef _scan_image_func = ffi.Int32 Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);
typedef _scan_frame_func = NativeScanFrameResult Function(
    ffi.Pointer<ffi.Uint8> y,
    ffi.Pointer<ffi.Uint8> u,
    ffi.Pointer<ffi.Uint8> v,
    ffi.Int32 height,
    ffi.Int32 width,
    ffi.Int32 bytesPerRow,
    ffi.Int32 bytesPerPixel,
    ffi.Bool isDocumentDetected,
    ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);

// Dart function signatures
typedef _ScanImageFunc = int Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);
typedef _ScanFrameFunc = NativeScanFrameResult Function(
    ffi.Pointer<ffi.Uint8> y,
    ffi.Pointer<ffi.Uint8> u,
    ffi.Pointer<ffi.Uint8> v,
    int height,
    int width,
    int bytesPerRow,
    int bytesPerPixel,
    bool isDocumentDetected,
    ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);

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

ScanFrameResult scanFrame(
    ffi.Pointer<ffi.Uint8> y,
    ffi.Pointer<ffi.Uint8> u,
    ffi.Pointer<ffi.Uint8> v,
    int height,
    int width,
    int bytesPerRow,
    int bytesPerPixel,
    bool isDocumentDetected,
    ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput) {
  NativeScanFrameResult nativeScanFrameResult = _scanFrame(y, u, v, height,
      width, bytesPerRow, bytesPerPixel, isDocumentDetected, encodedOutput);
  DetectedCorners detectedCorners = DetectedCorners(
    topLeft: Offset(nativeScanFrameResult.corners.topLeft.x,
        nativeScanFrameResult.corners.topLeft.y),
    topRight: Offset(nativeScanFrameResult.corners.topRight.x,
        nativeScanFrameResult.corners.topRight.y),
    bottomLeft: Offset(nativeScanFrameResult.corners.bottomLeft.x,
        nativeScanFrameResult.corners.bottomLeft.y),
    bottomRight: Offset(nativeScanFrameResult.corners.bottomRight.x,
        nativeScanFrameResult.corners.bottomRight.y),
  );
  return ScanFrameResult(
      corners: detectedCorners,
      outputBufferSize: nativeScanFrameResult.outputBufferSize);
}
