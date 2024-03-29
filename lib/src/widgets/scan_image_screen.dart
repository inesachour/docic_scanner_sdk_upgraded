import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/src/docic_mobile_sdk.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

class ScanImageScreen extends StatefulWidget {
  List<XFile> images;
  bool isFromGallery;

  ScanImageScreen(
      {super.key, required this.images, this.isFromGallery = false});

  @override
  State<ScanImageScreen> createState() => _ScanImageScreenState();
}

class _ScanImageScreenState extends State<ScanImageScreen> {
  TextStyle textStyle = const TextStyle(
      color: Colors.white, decoration: TextDecoration.none, fontSize: 14);

  late bool _isLastImage;
  late StreamSubscription sub; // Subscription for the isolate port
  late int imagesNumber;

  int _currentImageIndex = 0;
  bool _isLoading = true;
  Image? _currentScannedImage;
  List<Uint8List> processedImages = [];

  final pdf = pw.Document(); //pdf document

  Future<Image?> scanCurrentImage(XFile image) async {
    setState(() {
      _isLoading = true;
    });

    // Create a receive port from which the main isolate will receive messages from the created isolate
    final ReceivePort receivePort = ReceivePort();

    // Create an isolate to process the image in an isolated environment
    await Isolate.spawn<ScanImageArguments>(scanCurrentImageIsolated,
        ScanImageArguments(image, receivePort.sendPort));

    // Listen for the returned result from the created isolate
    sub = receivePort.listen((processedImageBytes) async {
      _isLoading = false;

      if (processedImageBytes != null) {
        _currentScannedImage = Image.memory(
          processedImageBytes,
          fit: BoxFit.fitHeight,
        );
      } else {
        _currentScannedImage = Image.file(
          File(widget.images[_currentImageIndex].path),
          fit: BoxFit.fitHeight,
        );
        processedImageBytes =
            await widget.images[_currentImageIndex].readAsBytes();
        //TODO : show snackbar or smthg to tell that no document was detected
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Aucun document n'a été détecté"),
          backgroundColor: Color(0xffff0f0f),
          elevation: 10.0,
        ));
      }

      processedImages.add(processedImageBytes);
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(pw.MemoryImage(processedImageBytes),
              fit: pw.BoxFit.fitHeight),
        );
      }));
      setState(() {});
    });

    return _currentScannedImage;
  }

  @override
  void initState() {
    super.initState();
    imagesNumber = widget.isFromGallery ? widget.images.length : 0;
    _isLastImage = (imagesNumber - 1 == _currentImageIndex);
    scanCurrentImage(widget.images[0]);
  }

  @override
  void dispose() async {
    Future.delayed(Duration.zero, () async {
      await sub.cancel();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isLoading)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Page ${_currentImageIndex + 1}",
                        style: textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _currentScannedImage == null
                    ? Image.file(
                        File(widget.images[_currentImageIndex].path),
                        fit: BoxFit.fitHeight,
                      )
                    : _currentScannedImage!,
                if (_isLoading)
                  const Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        color: Color(0xff808080),
                        strokeWidth: 7,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_isLoading)
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.crop,
                        color: Colors.white,
                      ),
                    ),
                  if (!_isLoading)
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.rotate_right,
                        color: Colors.white,
                      ),
                    ),
                  if (!_isLoading)
                    GestureDetector(
                      onTap: () async {
                        _currentImageIndex++;

                        if (_currentImageIndex < imagesNumber - 1) {
                          _currentScannedImage = null;
                          scanCurrentImage(widget.images[_currentImageIndex]);
                        } else if (_currentImageIndex == imagesNumber - 1) {
                          _isLastImage = true;
                          scanCurrentImage(widget.images[_currentImageIndex]);
                        } else {
                          //TODO SAVE PDF or SHOW IT for confirmation
                          String directory = "/storage/emulated/0/Download/";
                          bool dirDownloadExists =
                              await Directory(directory).exists();
                          if (dirDownloadExists) {
                            directory = "/storage/emulated/0/Download";
                          } else {
                            directory = "/storage/emulated/0/Downloads";
                          }
                          final file = File("$directory/example.pdf");
                          debugPrint(file.path);
                          await file.writeAsBytes(await pdf.save());
                        }
                        setState(() {});
                      },
                      child: Text(
                        _isLastImage ? "Confirmer\n($imagesNumber)" : "Suivant",
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
}

class ScanImageArguments {
  final XFile image;
  final SendPort sendPort;

  ScanImageArguments(this.image, this.sendPort);
}

// Function that will be executing in the created isolate
void scanCurrentImageIsolated(ScanImageArguments args) {
  // Allocate memory for the encoded output image
  Pointer<Pointer<Uint8>> encodedOutputImage = malloc.allocate(8);

  // Call the C++ function to scan the image and obtain the length of the encoded image
  int encodedImageLength = scanImage(args.image.path, encodedOutputImage);

  if (encodedImageLength == 0) {
    args.sendPort.send(null);
    return;
  }

  // Retrieve the pointer to the encoded image
  Pointer<Uint8> cppPointer = encodedOutputImage[0];
  Uint8List encodedImageBytes = cppPointer.asTypedList(encodedImageLength);

  malloc.free(cppPointer);
  malloc.free(encodedOutputImage);

  // Send the encoded image bytes to the send port
  args.sendPort.send(encodedImageBytes);
}
