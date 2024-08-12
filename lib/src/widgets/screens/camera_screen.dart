import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/document_scanner_ocr.dart';
import 'package:document_scanner_ocr/src/docic_mobile_sdk.dart';
import 'package:document_scanner_ocr/src/models/native_communication_models.dart';
import 'package:document_scanner_ocr/src/services/tessdata_service.dart';
import 'package:document_scanner_ocr/src/widgets/contours_painter.dart';
import 'package:document_scanner_ocr/src/widgets/screens/scan_image_from_camera.dart';
import 'package:document_scanner_ocr/src/widgets/screens/scan_image_from_gallery_screen.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  Function(ScannerResult) onFinish;

  CameraScreen({super.key, required this.onFinish});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isFlashOn = false;
  List<Image> _images = [];
  DetectedCorners? _detectedCorners;
  int _frameHeight = 0;
  int _frameWidth = 0;
  int detectedDocumentFramesNumber = 0;
  late Uint8List processedImage;
  double cameraWidthFactor = 1.1;

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
      _cameraController = CameraController(_cameras[0], ResolutionPreset.max, enableAudio: false);
      _cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        int skipFrame = 0;
        _cameraController!.startImageStream((image) async {
          skipFrame = (skipFrame + 1) % 15;
          if (skipFrame == 0) {
            final ffi.Pointer<ffi.Uint8> yData = malloc.allocate<ffi.Uint8>(image.planes[0].bytes.length);
            final ffi.Pointer<ffi.Uint8> uData = malloc.allocate<ffi.Uint8>(image.planes[1].bytes.length);
            final ffi.Pointer<ffi.Uint8> vData = malloc.allocate<ffi.Uint8>(image.planes[2].bytes.length);

            final Uint8List yDatapointerList = yData.asTypedList(image.planes[0].bytes.length);
            final Uint8List uDatapointerList = uData.asTypedList(image.planes[1].bytes.length);
            final Uint8List vDatapointerList = vData.asTypedList(image.planes[2].bytes.length);

            // Copy the Uint8List data to the allocated memory
            yDatapointerList.setAll(0, image.planes[0].bytes);
            uDatapointerList.setAll(0, image.planes[1].bytes);
            vDatapointerList.setAll(0, image.planes[2].bytes);

            ffi.Pointer<ffi.Pointer<ffi.Uint8>> encodedOutputImage = malloc.allocate(8);

            String dataPath = await TessdataService.copyTessdataFile();

            ScanFrameResult scanFrameResult = scanFrame(
                yData,
                uData,
                vData,
                image.height,
                image.planes[0].bytesPerRow,
                image.planes[1].bytesPerRow,
                image.planes[1].bytesPerPixel ?? 0,
                _detectedCorners != null && !_detectedCorners!.isEmpty(),
                dataPath,
                encodedOutputImage);

            setState(() {
              _detectedCorners = scanFrameResult.corners;
              _frameHeight = image.height;
              _frameWidth = image.planes[0].bytesPerRow;
            });

            if (_detectedCorners != null && !_detectedCorners!.isEmpty()) {
              detectedDocumentFramesNumber++;
            } else {
              detectedDocumentFramesNumber = 0;
            }

            if (detectedDocumentFramesNumber == 2) {
              ffi.Pointer<ffi.Uint8> cppPointer = encodedOutputImage[0];
              Uint8List encodedImageBytes = cppPointer.asTypedList(scanFrameResult.outputBufferSize);
              processedImage = encodedImageBytes;

              await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ScanImageFromCameraScreen(
                        processedImage: processedImage,
                        onFinish: widget.onFinish,
                      )
                  ));

              malloc.free(cppPointer);
              detectedDocumentFramesNumber = 0;
            }

            malloc.free(yData);
            malloc.free(uData);
            malloc.free(vData);
            malloc.free(encodedOutputImage);
          }
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
                                _cameraController!.setFlashMode(FlashMode.torch);
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
                        Container(
                          child: FractionallySizedBox(
                            widthFactor: cameraWidthFactor,
                            child: CameraPreview(_cameraController!),
                          ),
                          color: Colors.black,
                        ),
                        if (_detectedCorners != null && !_detectedCorners!.isEmpty())
                          CustomPaint(
                            painter: ContoursPainter(
                              detectedCorners: _detectedCorners!,
                              imageHeight: _frameHeight,
                              imageWidth: _frameWidth,
                              cameraWidthFactor: cameraWidthFactor,
                              color: Colors.red,
                            ),
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
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ScanImageFromGalleryScreen(
                                              images: images,
                                              onFinish: widget.onFinish,
                                        )
                                    ));
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
                            onTap: () async {
                              XFile image = await _cameraController!.takePicture();
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ScanImageFromGalleryScreen(
                                            images: [image],
                                            onFinish: widget.onFinish,
                                          )
                                  ));
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
