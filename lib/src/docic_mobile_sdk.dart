import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

// C function signatures
typedef _scan_image_func = ffi.Int32 Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);

// Dart function signatures
typedef _ScanImageFunc = int Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);

// Getting the library
ffi.DynamicLibrary _lib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libdocic_mobile_sdk.so')
    : ffi.DynamicLibrary.process();

// Looking for the functions
final _ScanImageFunc _scanImage =
    _lib.lookupFunction<_scan_image_func, _ScanImageFunc>('scanFromImage');

int scanImage(String path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput) {
  return _scanImage(path.toNativeUtf8(), encodedOutput);
}
