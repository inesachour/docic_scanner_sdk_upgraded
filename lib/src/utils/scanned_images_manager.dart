import 'dart:typed_data';

class ScannedImagesManager {
  static final ScannedImagesManager _instance = ScannedImagesManager._internal();
  factory ScannedImagesManager() => _instance;

  ScannedImagesManager._internal();

  List<Uint8List> imageBytes = [];
}
