import 'dart:io';
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class ImageEditingService{

  static Future<File> createTemporaryFile(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    File tempFile = File('${directory.path}/$fileName');
    return tempFile.writeAsBytes(bytes);
  }

  static Future<void> deleteTemporaryFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }


  static Future<Uint8List?> cropImage(Uint8List bytes) async {
    final String fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    File tempFile = await createTemporaryFile(bytes, fileName);

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: tempFile.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Recadrer',
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,),
      ],
    );

    Uint8List? result;
    if(croppedFile != null){
      result = await croppedFile.readAsBytes();
    }

    await deleteTemporaryFile(tempFile.path);

    return result;
  }
}