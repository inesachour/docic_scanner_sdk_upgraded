#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/calib3d.hpp>
#include <iostream>
#include <map>

using namespace cv;
using namespace std;


class DocumentScanner {
public:
    DocumentScanner();
    static Mat preprocessImage(const Mat& image);
    static vector<vector<Point>> detectContour(const Mat& image);
    static vector<Point> findCorners(const vector<vector<Point>>& contours);
    static Point computeCentroid(const vector<Point>& points);
    static vector<Point> orderPoints(const vector<Point>& points);
    static Mat fillArea(const Mat& image, const vector<Point>& corners, const Scalar& fillColor, const double transparency);
    static Mat transformAndCropImage(const Mat& image, const vector<Point>& orderedCorners);
    static struct vector<Point> scanDocument(Mat image, bool isDocumentDetected, Mat* resultImage);
    static int detectRotationAngle(const Mat& image);
};