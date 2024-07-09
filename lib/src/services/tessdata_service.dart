import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class TessdataService{

  static String configFilePath = "assets/tessdata_config.json";
  static String tessDataFilesPath = "assets/tessdata";

  static Future<String> copyTessdataFile() async{
    final String config = await rootBundle.loadString(configFilePath);
    Map<String, dynamic> files = jsonDecode(config);

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String saveDirectory = '${appDirectory.path}/tessdata';

    final Directory tessdataDir = Directory(saveDirectory);
    if (!await tessdataDir.exists()) {
      await tessdataDir.create(recursive: true);
    }

    for (var file in files["files"]) {
      File tessdataFile = File('$saveDirectory/$file');
      if (!await tessdataFile.exists()) {
        final ByteData data = await rootBundle.load('$tessDataFilesPath/$file');
        final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes,);
        await tessdataFile.writeAsBytes(bytes);
      }
    }
    return saveDirectory;
  }
}