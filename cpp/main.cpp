#include <opencv2/opencv.hpp>
#include "document_processor.h"

using namespace cv;
using namespace std;

// Avoiding name mangling
extern "C" {
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    int scanFromImage(char* path, char* dataPath, uchar** encodedOutput) {
        DocumentProcessor documentProcessor = DocumentProcessor();
        return documentProcessor.processImage(path, dataPath, encodedOutput);
    }

    __attribute__((visibility("default"))) __attribute__((used))
    struct ScanFrameResult scanFromLiveCamera(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel, bool isDocumentDetected, char* dataPath, uchar** encodedOutput) {
        DocumentProcessor documentProcessor = DocumentProcessor();
        return documentProcessor.processFrame(y, u, v, height, width, bytesPerRow, bytesPerPixel, isDocumentDetected, dataPath, encodedOutput);
    }

}