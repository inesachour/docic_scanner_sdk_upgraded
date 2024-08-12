#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <string>


using namespace cv;
using namespace std;

class TesseractOCR {
public:
    TesseractOCR();
    static Mat preprocessImage(const Mat& image);
    static string extractText(const Mat& image, char* dataPath);
    static int detectRotationAngle(const Mat& image, char* dataPath);
};