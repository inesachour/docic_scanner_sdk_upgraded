import 'package:flutter/material.dart';

class ScannedImage extends StatefulWidget {
  const ScannedImage({super.key});

  @override
  State<ScannedImage> createState() => _ScannedImageState();
}

class _ScannedImageState extends State<ScannedImage> {
  TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Annuler",
                    style: textStyle,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Page 1",
                    style: textStyle,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Suivant",
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Container(
            color: Colors.grey,
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
                  onTap: () {},
                  child: const Icon(
                    Icons.crop,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
