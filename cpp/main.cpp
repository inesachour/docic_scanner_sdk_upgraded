#include <opencv2/opencv.hpp>
#include "document_scanner.h"
#include "tesseract_ocr.h"

using namespace cv;
using namespace std;

// Avoiding name mangling
extern "C" {
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    int scanFromImage(char* path, uchar** encodedOutput) {
        DocumentScanner documentScanner = DocumentScanner();
        return documentScanner.scanImage(path, encodedOutput);
    }

    __attribute__((visibility("default"))) __attribute__((used))
    struct ScanFrameResult scanFromLiveCamera(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel, bool isDocumentDetected, uchar** encodedOutput) {
        DocumentScanner documentScanner = DocumentScanner();
        return documentScanner.scanFrame(y, u, v, height, width, bytesPerRow, bytesPerPixel, isDocumentDetected, encodedOutput);
    }

    __attribute__((visibility("default"))) __attribute__((used))
    int getOrientation(char* imagePath, char* dataPath) {
        TesseractOCR ocr = TesseractOCR();
        return ocr.detectRotationAngle(imagePath, dataPath);
    }

}