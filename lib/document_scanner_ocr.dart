import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/src/scanned_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocumentScannerOcr extends StatefulWidget {
  const DocumentScannerOcr({super.key});

  @override
  State<DocumentScannerOcr> createState() => _DocumentScannerOcrState();
}

class _DocumentScannerOcrState extends State<DocumentScannerOcr> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isFlashOn = false;
  List<Image> _images = [];

  TextStyle textStyle = TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      if(value.isEmpty){
        throw("No camera was found!");
      }
      else{
        _cameras = value;
      }
      _cameraController = CameraController(_cameras[0], ResolutionPreset.max);
      _cameraController!.initialize().then((_) {
        if(!mounted){
          return;
        }
        setState(() {});
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !(_cameraController!.value.isInitialized)) {
      return Center(
        child: SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            color: Colors.grey,
          ),
        ),
      );
    }
    return Column(
      children: [

        Expanded(
          child: Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      _isFlashOn = !_isFlashOn;
                      if(_isFlashOn){
                        _cameraController!.setFlashMode(FlashMode.torch);
                      }
                      else{
                        _cameraController!.setFlashMode(FlashMode.off);
                      }
                    });
                  },
                  child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white,),
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
                    onTap: (){},
                    child: Icon(Icons.photo, color: Colors.white,),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: !_images.isEmpty ?
                  Container() :
                  Text("Confirmer \n(${_images.length})", style: textStyle, textAlign: TextAlign.center,),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
