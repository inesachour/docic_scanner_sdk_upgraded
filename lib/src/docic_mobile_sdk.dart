import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

// C function signatures
typedef _version_func = ffi.Pointer<Utf8> Function();
typedef _scan_image_func = ffi.Int32 Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);

// Dart function signatures
typedef _VersionFunc = ffi.Pointer<Utf8> Function();
typedef _ScanImageFunc = int Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput);

// Getting a library that holds needed symbols
ffi.DynamicLibrary _lib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libdocic_mobile_sdk.so')
    : ffi.DynamicLibrary.process();

// Looking for the functions
final _VersionFunc _version =
    _lib.lookup<ffi.NativeFunction<_version_func>>('version').asFunction();

final _ScanImageFunc _scanImage =
    _lib.lookupFunction<_scan_image_func, _ScanImageFunc>('scanFromImage');

String opencvVersion() {
  return _version().toDartString();
}

int scanImage(String path, ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutput) {
  return _scanImage(path.toNativeUtf8(), encodedOutput);
}
