#include "document_scanner.h"

DocumentScanner::DocumentScanner()
{}

// Preprocess the input image for document scanning
Mat DocumentScanner::preprocessImage(const Mat& image)
{
    Mat gray;

    // Convert to grayscale
    cvtColor(image, gray, COLOR_BGR2GRAY);

    // Determine kernel size for morphological operations based on image dimensions
    int kernelSize = std::min(19, std::max(3, int(0.0027 * image.rows + 0.0027 * image.cols)));
    if (kernelSize % 2 == 0) kernelSize--;
    Mat kernel = getStructuringElement(MORPH_RECT, Size(kernelSize, kernelSize));

    // Apply morphological closing operation
    morphologyEx(gray, gray, MORPH_CLOSE, kernel, Point(-1, -1), 3);

    // Convert to grayscale and apply Gaussian blur
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

// Returns the detected corners
vector<Point> DocumentScanner::scanDocument(Mat image, bool isDocumentDetected, Mat* resultImage)
{
    Mat processedImage = image.clone();
    processedImage = preprocessImage(processedImage);
    vector<vector<Point>> contours = detectContour(processedImage);

    if (contours.empty()) {
        return {};
    }

    vector<Point> orderedCorners = findCorners(contours);

    if (isDocumentDetected) {
        *resultImage = transformAndCropImage(image, orderedCorners);
    }

    return orderedCorners;
}

// Detect the predominant rotation angle from image lines
int DocumentScanner::detectRotationAngle(const Mat& image)
{
    map<int, int> anglesNumbers;

    Mat gray;
    cvtColor(image, gray, COLOR_BGR2GRAY);

    Mat edges;
    // Detect edges using Canny
    Canny(gray, edges, 100, 200, 3);

    vector<Vec4i> lines;
    // Detect lines using Hough Transform
    HoughLinesP(edges, lines, 1, CV_PI / 180, 150, 100, 30);

    Mat imageWithLines = image.clone();

    for (size_t i = 0; i < lines.size(); i++) {
        Vec4i l = lines[i];
        double dx = l[2] - l[0];
        double dy = l[3] - l[1];
        double angle = atan2(dy, dx) * 180 / CV_PI;

        if (angle < 0) {
            angle += 360;
        }

        // Consider only angles close to multiples of 90 degrees
        if (abs(angle) <= 10 || abs(angle - 90) <= 10 || abs(angle - 180) <= 10 || abs(angle - 270) <= 10 || abs(angle - 360) <= 10) {
            int ceiledAngle = ceil(angle);

            int distances[5] = { ceiledAngle, abs(ceiledAngle - 90), abs(ceiledAngle - 180), abs(ceiledAngle - 270), abs(ceiledAngle - 360) };

            // Find the closest multiple of 90 degrees
            int minIndex = 0;
            for (int i = 1; i < 5; ++i) {
                if (distances[i] < distances[minIndex]) {
                    minIndex = i;
                }
            }

            if (minIndex == 4) {
                ceiledAngle = 0;
            }
            else {
                ceiledAngle = minIndex * 90;
            }

            auto it = anglesNumbers.find(ceiledAngle);
            if (it != anglesNumbers.end()) {
                ++(it->second);
            }
            else {
                anglesNumbers.insert(make_pair(ceiledAngle, 1));
            }
        }
    }

    // Find the angle with the highest frequency
    int maxKey = 0;
    if (!anglesNumbers.empty()) {
        auto it = anglesNumbers.begin();
        maxKey = it->first;
        int maxValue = it->second;

        for (++it; it != anglesNumbers.end(); ++it) {
            if (it->second > maxValue) {
                maxKey = it->first;
                maxValue = it->second;
            }
        }
    }


    return maxKey;
}
