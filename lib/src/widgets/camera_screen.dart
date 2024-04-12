import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/src/docic_mobile_sdk.dart';
import 'package:document_scanner_ocr/src/widgets/scan_image_screen.dart';
import 'package:ffi/ffi.dart';
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
  DetectedCorners? _detectedCorners;

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
        _cameraController!.startImageStream((image) async {
          final ffi.Pointer<ffi.Uint8> yData = malloc.allocate<ffi.Uint8>(image.planes[0].bytes.length);
          final ffi.Pointer<ffi.Uint8> uData = malloc.allocate<ffi.Uint8>(image.planes[1].bytes.length);
          final ffi.Pointer<ffi.Uint8> vData = malloc.allocate<ffi.Uint8>(image.planes[2].bytes.length);

          final Uint8List yDatapointerList = yData.asTypedList(image.planes[0].bytes.length);
          final Uint8List uDatapointerList = yData.asTypedList(image.planes[1].bytes.length);
          final Uint8List vDatapointerList = yData.asTypedList(image.planes[2].bytes.length);

          // Copy the Uint8List data to the allocated memory
          yDatapointerList.setAll(0, image.planes[0].bytes);
          uDatapointerList.setAll(0, image.planes[1].bytes);
          vDatapointerList.setAll(0, image.planes[2].bytes);

          DetectedCorners detectedCorners = scanFrame(yData, uData, vData, image.height, image.width);
          debugPrint(detectedCorners.topLeft.dx.toString());
          setState(() {
            _detectedCorners = detectedCorners;
          });

          malloc.free(yData);
          malloc.free(uData);
          malloc.free(vData);
        });
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
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_cameraController!),
                        if (_detectedCorners != null) CustomPaint(
                          painter: ContoursPainter(detectedCorners: _detectedCorners!),
                          size: Size.infinite,
                        ),
                      ],
                    ),
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
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }
}

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
