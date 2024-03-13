import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class DocumentScannerOcr extends StatefulWidget {
  const DocumentScannerOcr({super.key});

  @override
  State<DocumentScannerOcr> createState() => _DocumentScannerOcrState();
}

class _DocumentScannerOcrState extends State<DocumentScannerOcr> {
  CameraController? controller;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      if(value.isEmpty){
        throw("No camera was found!");
      }
      else{
        cameras = value;
      }
      controller = CameraController(cameras[0], ResolutionPreset.max);
      controller!.initialize().then((_) {
        if(!mounted){
          return;
        }
        setState(() {});
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !(controller!.value.isInitialized)) {
      return Container();
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
                  onTap: (){},
                  child: Icon(Icons.flash_off, color: Colors.white,),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 8,
          child: AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: CameraPreview(controller!),
          ),
        ),

        Expanded(
          child: Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){},
                  child: Icon(Icons.photo, color: Colors.white,),
                ),

                GestureDetector(
                  onTap: (){},
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),

                Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
