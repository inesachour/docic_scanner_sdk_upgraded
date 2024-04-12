#include <opencv2/opencv.hpp>
#include "document_scanner.h"

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
    struct DetectedCorners scanFromLiveCamera(char* y, char* u, char* v, int height, int width) {
        DocumentScanner documentScanner = DocumentScanner();
        return documentScanner.scanFrame(y, u, v, height, width);
    }

}