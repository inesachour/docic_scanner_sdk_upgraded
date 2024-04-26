import 'package:camera/camera.dart';
import 'package:document_scanner_ocr/src/widgets/screens/camera_screen.dart';
import 'package:document_scanner_ocr/src/widgets/screens/scan_image_from_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

class MockImagePicker extends Mock implements ImagePicker {
  @override
  Future<List<XFile>> pickMultiImage(
          {double? maxWidth,
          double? maxHeight,
          int? imageQuality,
          bool requestFullMetadata = true}) =>
      super.noSuchMethod(Invocation.method(#start, []),
          returnValue: Future(() => <XFile>[]));
}

class MockCameraDescription extends Mock implements CameraDescription {}

class MockAvailableCameras extends Mock {
  Future<List<CameraDescription>> call() =>
      super.noSuchMethod(Invocation.method(#start, []),
          returnValue: Future(() => <CameraDescription>[]));
}

void main() {
  late List<XFile> mockImages = [
    XFile('images/tests/document1.jpg'),
    XFile('images/tests/document1.jpg'),
  ];

  setUpAll(() {
    mockImages = [
      XFile('images/tests/document1.jpg'),
      XFile('images/tests/document1.jpg'),
    ];
  });

  group("ScanImageScreen Widget Tests", () {
    testWidgets('ScanImageScreen UI Test', (WidgetTester tester) async {
      // Build our widget and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: ScanImageFromGalleryScreen(
          images: mockImages,
          onFinish: (_){},
        ),
      ));

      expect(find.text('Page 1'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.text('Suivant'));
      await tester.pump();
      expect(find.text('Page 2'), findsOneWidget);
    });

    /*testWidgets('ScanImageScreen Loading Test', (WidgetTester tester) async {
      // Build our widget and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: ScanImageScreen(
          images: mockImages,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });*/
  });

  group("CameraScreen Widget Tests", () {
    late Future<List<CameraDescription>> Function() availableCameras;

    setUp(() {
      availableCameras = MockAvailableCameras().call;
    });

    testWidgets('CameraScreen Loading Test', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraScreen(
          onFinish: (_){},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
