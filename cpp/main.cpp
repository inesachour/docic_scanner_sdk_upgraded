#include <opencv2/opencv.hpp>
#include "document_scanner.h"

using namespace cv;
using namespace std;

// Avoiding name mangling
extern "C" {
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const char* version() {
        return CV_VERSION;
    }

    __attribute__((visibility("default"))) __attribute__((used))
    int scanFromImage(char* path, uchar** encodedOutput) {
        DocumentScanner documentScanner = DocumentScanner();
        return documentScanner.scanImage(path, encodedOutput);
    }
}