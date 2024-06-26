#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <string>


using namespace cv;
using namespace std;

class TesseractOCR {
public:
    TesseractOCR();
    static string extractText(const char* imagePath);
    static int detectRotationAngle(const char* imagePath);
};