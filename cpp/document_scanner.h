#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/calib3d.hpp>
#include <iostream>


using namespace cv;
using namespace std;

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
    static pair<Mat, bool> scanFrame(const Mat& image);
    static int scanImage(char* path, uchar** encodedOutput);
};