#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/calib3d.hpp>
#include <iostream>


using namespace cv;
using namespace std;

struct Coordinate
{
    double x;
    double y;
};

struct DetectedCorners
{
    Coordinate topLeft;
    Coordinate topRight;
    Coordinate bottomLeft;
    Coordinate bottomRight;
};

class DocumentScanner {
private:
    static int detectedDocumentFrames;
public:
    DocumentScanner();
    static Mat preprocessImage(const Mat& image);
    static vector<vector<Point>> detectContour(const Mat& image);
    static vector<Point> findCorners(const vector<vector<Point>>& contours);
    static vector<Point> orderPoints(const vector<Point>& points);
    static Mat fillArea(const Mat& image, const vector<Point>& corners, const Scalar& fillColor, const double transparency);
    static Mat transformAndCropImage(const Mat& image, const vector<Point>& orderedCorners);
    static struct Coordinate createCoordinate(double x, double y);
    static struct DetectedCorners createDetectedCorners(Coordinate topLeft, Coordinate topRight, Coordinate bottomLeft, Coordinate bottomRight);
    static struct DetectedCorners scanFrame(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel);
    static Mat convertYUVtoRGB(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width ,int bytesPerRow, int bytesPerPixel);
    static int scanImage(char* path, uchar** encodedOutput);
};