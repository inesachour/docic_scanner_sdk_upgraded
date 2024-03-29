import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/src/widgets/scan_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isFlashOn = false;
  List<Image> _images = [];

  TextStyle textStyle = const TextStyle(color: Colors.white);

  Future<List<XFile>> pickImagesFromGallery() async {
    List<XFile> images = await ImagePicker().pickMultiImage();
    return images;
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      if (value.isEmpty) {
        throw ("No camera was found!");
      } else {
        _cameras = value;
      }
      _cameraController = CameraController(_cameras[0], ResolutionPreset.max,
          enableAudio: false);
      _cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController == null ||
              !(_cameraController!.value.isInitialized)
          ? const Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 25.0),
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFlashOn = !_isFlashOn;
                              if (_isFlashOn) {
                                _cameraController!
                                    .setFlashMode(FlashMode.torch);
                              } else {
                                _cameraController!.setFlashMode(FlashMode.off);
                              }
                            });
                          },
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final images = await pickImagesFromGallery();
                              if (images.isNotEmpty) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ScanImageScreen(
                                          images: images,
                                          isFromGallery: true,
                                        )));
                              }
                            },
                            child: const Icon(
                              Icons.photo,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              //showDialog(barrierDismissible: false ,context: context, builder: (context) => AddPagePopup());
                            },
                            child: Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _images.isEmpty
                              ? Container()
                              : Text(
                                  "Confirmer \n(${_images.length})",
                                  style: textStyle,
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
