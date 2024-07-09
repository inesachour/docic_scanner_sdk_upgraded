#include "document_scanner.h"

DocumentScanner::DocumentScanner()
{}

// Preprocess the input image for document scanning
Mat DocumentScanner::preprocessImage(const Mat& image)
{
    Mat imageClone;
    Mat gray;

    // Determine kernel size for morphological operations based on image dimensions
    int kernelSize = std::min(19, std::max(3, int(0.0026 * image.rows + 0.0026 * image.cols)));
    if (kernelSize % 2 == 0) kernelSize--;
    Mat kernel = getStructuringElement(MORPH_RECT, Size(kernelSize, kernelSize));

    // Apply morphological closing operation
    morphologyEx(image, imageClone, MORPH_CLOSE, kernel, Point(-1, -1), 3);

    // Convert to grayscale and apply Gaussian blur
    cvtColor(imageClone, gray, COLOR_BGR2GRAY);
    GaussianBlur(gray, gray, Size(kernelSize, kernelSize), 0);

    // Adaptive thresholding to create a binary image
    int x = (kernelSize * kernelSize) / 2;
    int x2 = (x % 2 == 0 ? x + 1 : (x == 1) ? 3 : x);
    int thresholdBlockSize = std::min(125, x2);
    adaptiveThreshold(gray, gray, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, thresholdBlockSize, 2);

    return gray;
}

// Detect contours in the given image
vector<vector<Point>> DocumentScanner::detectContour(const Mat& image)
{
    vector<vector<Point>> contours;
    findContours(image, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

    // Filter out contours with areas less than 50% of the image
    double imageArea = image.cols * image.rows;
    contours.erase(remove_if(contours.begin(), contours.end(), [imageArea](const vector<Point>& contour) {
        return contourArea(contour, false) < 0.2 * imageArea;
    }), contours.end());

    // Sort contours by area in descending order
    sort(contours.begin(), contours.end(), [](const vector<Point>& a, const vector<Point>& b) {
        return contourArea(a, false) > contourArea(b, false);
    });

    return contours;
}

// Find the four corners of the document from the detected contours
vector<Point> DocumentScanner::findCorners(const vector<vector<Point>>& contours)
{
    if (contours.empty()) {
        return {};
    }
    vector<Point> corners = {};

    for (const auto& c : contours) {
        // Approximate the contour.
        double epsilon = 0.02 * arcLength(c, true);

        approxPolyDP(c, corners, epsilon, true);

        if (corners.size() == 4) {
            break;
        }
    }
    if (corners.size() != 4) {
        return {};
    }

    // Order the points to get a rectangle
    vector<Point> orderedCorners = orderPoints(corners);
    return orderedCorners;
}

// Calculate the centroid of a set of points
Point DocumentScanner::computeCentroid(const vector<Point>& points)
{
    Point centroid;
    for (const Point& pt : points) {
        centroid += pt;
    }
    centroid.x /= points.size();
    centroid.y /= points.size();
    return centroid;
}

// Order four points in a clockwise direction
vector<Point> DocumentScanner::orderPoints(const vector<Point>& points)
{
    vector<Point> rect(4);
    vector<Point> sortedPts = points;

    Point centroid = computeCentroid(points);

    // Sort points based on angle relative to centroid
    sort(sortedPts.begin(), sortedPts.end(), [&centroid](const Point& p1, const Point& p2) {
        double angle1 = atan2(p1.y - centroid.y, p1.x - centroid.x);
        double angle2 = atan2(p2.y - centroid.y, p2.x - centroid.x);
        return angle1 < angle2;
    });

    // Assign sorted points to the rectangle in clockwise order
    rect[0] = sortedPts[0];
    rect[1] = sortedPts[1];
    rect[2] = sortedPts[2];
    rect[3] = sortedPts[3];

    return rect;
}

// Fill the area within the four corners with a specified color and transparency
Mat DocumentScanner::fillArea(const Mat& image, const vector<Point>& corners, const Scalar& fillColor, const double transparency)
{
    if (corners.empty()) {
        return image;
    }

    // Create a mask to represent the filled area
    Mat mask = Mat::zeros(image.size(), CV_8UC1);

    // Draw contours on the mask
    vector<vector<Point>> contour;
    contour.push_back(corners);
    drawContours(mask, contour, 0, Scalar(255, 0, 0), FILLED);

    // Create a clone of the input image and fill the area with the specified color
    Mat filledImage = image.clone();
    filledImage.setTo(fillColor, mask);
    // Combine the original image and the filled area with transparency
    addWeighted(image, 1 - transparency, filledImage, transparency, 0, filledImage);

    return filledImage;
}

// Transform and crop the image based on the ordered corners
Mat DocumentScanner::transformAndCropImage(const Mat& image, const vector<Point>& orderedCorners)
{
    if (orderedCorners.empty()) {
        return {};
    }

    // Extract the four corners
    Point tl = orderedCorners[0];
    Point tr = orderedCorners[1];
    Point br = orderedCorners[2];
    Point bl = orderedCorners[3];

    // Calculate the width and height of the new image
    float widthA = sqrt(pow((br.x - bl.x), 2) + pow((br.y - bl.y), 2));
    float widthB = sqrt(pow((tr.x - tl.x), 2) + pow((tr.y - tl.y), 2));
    int maxWidth = max(static_cast<int>(widthA), static_cast<int>(widthB));

    // Finding the maximum height.
    float heightA = sqrt(pow((tr.x - br.x), 2) + pow((tr.y - br.y), 2));
    float heightB = sqrt(pow((tl.x - bl.x), 2) + pow((tl.y - bl.y), 2));
    int maxHeight = max(static_cast<int>(heightA), static_cast<int>(heightB));

    // Calculate the ratio for resizing
    double widthRatio = maxWidth / image.size().width;
    double heightRatio = maxHeight / image.size().height;

    int destinationWidth, destinationHeight;

    // Determine the final dimensions while maintaining the original aspect ratio
    if (widthRatio > heightRatio) {
        destinationWidth = image.size().width;
        destinationHeight = floor((maxHeight / (double)maxWidth) * image.size().width);
    }
    else {
        destinationHeight = image.size().height;
        destinationWidth = floor((maxWidth / (double)maxHeight) * image.size().height);
    }

    // Final destination co-ordinates.
    vector<Point> destinationCorners = { Point2f(0, 0), Point2f(destinationWidth, 0), Point2f(destinationWidth, destinationHeight), Point2f(0, destinationHeight) };

    Mat orderedCornersMat = Mat(orderedCorners).reshape(1);
    orderedCornersMat.convertTo(orderedCornersMat, CV_32F);

    Mat destinationCornersMat = Mat(destinationCorners).reshape(1);
    destinationCornersMat.convertTo(destinationCornersMat, CV_32F);

    // Calculate the perspective transformation matrix
    Mat m = getPerspectiveTransform(orderedCornersMat, destinationCornersMat);

    // Apply the perspective transformation to the image
    Mat finalImage;
    warpPerspective(image, finalImage, m, Size(destinationCorners[2].x, destinationCorners[2].y), INTER_LINEAR);

    return finalImage;
}

Coordinate DocumentScanner::createCoordinate(double x, double y)
{
    Coordinate coordinate;
    coordinate.x = x;
    coordinate.y = y;
    return coordinate;
}

ScanFrameResult DocumentScanner::createScanFrameResult(Coordinate topLeft, Coordinate topRight, Coordinate bottomLeft, Coordinate bottomRight, int outputBufferSize)
{
    DetectedCorners detectedCorners;
    detectedCorners.topLeft = topLeft;
    detectedCorners.topRight = topRight;
    detectedCorners.bottomLeft = bottomLeft;
    detectedCorners.bottomRight = bottomRight;

    ScanFrameResult scanFrameResult;
    scanFrameResult.corners = detectedCorners;
    scanFrameResult.outputBufferSize = outputBufferSize;

    return scanFrameResult;
}

// Function that returns the detected corners and the buffer length if a document is detected (after a certain number of frames)
ScanFrameResult DocumentScanner::scanFrame(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel, bool isDocumentDetected, char* dataPath, uchar** encodedOutput)
{
    Mat image = convertYUVtoRGB(y, u, v, height, width, bytesPerRow, bytesPerPixel);

    if (image.empty()) {
        return createScanFrameResult(createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), 0);
    }

    struct DetectedCorners coordinate;

    Mat processedImage = image.clone();
    processedImage = preprocessImage(processedImage);
    vector<vector<Point>> contours = detectContour(processedImage);
    vector<uchar> buf;
    int bufferSize = 0;

    if (contours.empty()) {
        return createScanFrameResult(createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), 0);
    }

    vector<Point> orderedCorners = findCorners(contours);

    if (isDocumentDetected) {
        Mat result = transformAndCropImage(image, orderedCorners);

        TesseractOCR ocr = TesseractOCR();
        int rotationAngle = ocr.detectRotationAngle(result,dataPath);
        result = rotateImage(result, rotationAngle);

        imencode(".jpg", result, buf);
        *encodedOutput = (unsigned char*)malloc(buf.size());
        for (int i = 0; i < buf.size(); i++)
            (*encodedOutput)[i] = buf[i];
        bufferSize = (int)buf.size();
    }

    return createScanFrameResult(
            createCoordinate((double)orderedCorners[0].x / image.size().width, (double)orderedCorners[0].y / image.size().height),
            createCoordinate((double)orderedCorners[1].x / image.size().width, (double)orderedCorners[1].y / image.size().height),
            createCoordinate((double)orderedCorners[3].x / image.size().width, (double)orderedCorners[3].y / image.size().height),
            createCoordinate((double)orderedCorners[2].x / image.size().width, (double)orderedCorners[2].y / image.size().height),
            bufferSize
    );
}

// Function that converts YUV420 image to RGB
Mat DocumentScanner::convertYUVtoRGB(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel)
{
    int uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    Mat image(height, width, CV_8UC3);

    // Iterate over each pixel in the image
    for (int i = 0; i < width; ++i)
    {
        for (int j = 0; j < height; ++j)
        {
            // Calculate indices for YUV components
            uvIndex = bytesPerPixel * ((int)floor(i / 2)) + bytesPerRow * ((int)floor(j / 2));
            index = j * width + i;

            // Extract YUV components for the current pixel
            yp = y[index];
            up = u[uvIndex];
            vp = v[uvIndex];

            // Convert YUV to RGB
            rt = round(yp + vp * 1436 / 1024 - 179);
            gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
            bt = round(yp + up * 1814 / 1024 - 227);

            // Clip RGB values to [0, 255]
            r = rt < 0 ? 0 : (rt > 255 ? 255 : rt);
            g = gt < 0 ? 0 : (gt > 255 ? 255 : gt);
            b = bt < 0 ? 0 : (bt > 255 ? 255 : bt);

            // Set RGB values for the current pixel in the image
            image.at<Vec3b>(j, i) = Vec3b(b, g, r);
        }
    }

    // Rotate the image clockwise
    rotate(image, image, ROTATE_90_CLOCKWISE);

    return image;
}

// Function to scan an entire image and return the transformed and cropped document
int DocumentScanner::scanImage(char* path, char* dataPath, uchar** encodedOutput)
{
    Mat image = imread(path);

    if (image.empty()) {
        return 0;
    }

    Mat processedImage = image.clone();
    processedImage = preprocessImage(processedImage);
    vector<vector<Point>> contours = detectContour(processedImage);
    vector<Point> orderedCorners = findCorners(contours);
    vector<uchar> buf;
    if (orderedCorners.empty()) {
        return 0;
    }
    else {
        Mat result = transformAndCropImage(image, orderedCorners);

        TesseractOCR ocr = TesseractOCR();
        int rotationAngle = ocr.detectRotationAngle(result, dataPath);
        result = rotateImage(result, rotationAngle);

        imencode(".jpg", result, buf);
        *encodedOutput = (unsigned char*)malloc(buf.size());
        for (int i = 0; i < buf.size(); i++)
            (*encodedOutput)[i] = buf[i];
        return (int)buf.size();
    }
}

Mat DocumentScanner::rotateImage(Mat image, int angle)
{
    Mat result = image;

    if (angle == 90) {
        rotate(image, image, ROTATE_90_CLOCKWISE);
    }
    else if (angle == 180) {
        rotate(image, image, ROTATE_180);
    }
    else if (angle == 270) {
        rotate(image, image, ROTATE_90_COUNTERCLOCKWISE);
    }

    return result;
}
