#include "document_processor.h"

DocumentProcessor::DocumentProcessor() 
{}

int DocumentProcessor::processImage(char* path, char* dataPath, uchar** encodedOutput)
{
	Mat image = imread(path);

	if (image.empty()) {
		return 0;
	}

	image = resizeBigImage(image, 9999999);

	DocumentScanner scanner = DocumentScanner();
	Mat resultImage;
	vector<Point> result = scanner.scanDocument(image, true, &resultImage);

	if (result.empty()) {
		return 0;
	}

	resultImage = combinedAutomaticRotation(resultImage, dataPath);

	vector<uchar> buf;
	int bufferSize = 0;

	imencode(".jpg", resultImage, buf);
	*encodedOutput = (unsigned char*)malloc(buf.size());
	for (int i = 0; i < buf.size(); i++)
		(*encodedOutput)[i] = buf[i];
	return (int)buf.size();
}

ScanFrameResult DocumentProcessor::processFrame(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel, bool isDocumentDetected, char* dataPath, uchar** encodedOutput)
{
	Mat image = convertYUVtoRGB(y, u, v, height, width, bytesPerRow, bytesPerPixel);

	if (image.empty()) {
		return createScanFrameResult(createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), 0);
	}

	image = resizeBigImage(image, 9999999);

	DocumentScanner scanner = DocumentScanner();
	Mat resultImage;
	vector<Point> orderedCorners = scanner.scanDocument(image, isDocumentDetected, &resultImage);

	if (orderedCorners.empty()) {
		return createScanFrameResult(createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), createCoordinate(0, 0), 0);
	}

	vector<uchar> buf;
	int bufferSize = 0;

	if (isDocumentDetected) {
		resultImage = combinedAutomaticRotation(resultImage, dataPath);

		imencode(".jpg", resultImage, buf);
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

// Converts YUV420 image to RGB
Mat DocumentProcessor::convertYUVtoRGB(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel)
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

// Resize an image if it exceeds a specified maximum size
Mat DocumentProcessor::resizeBigImage(const Mat& image, int maxSize)
{
	int totalPixels = image.cols * image.rows;

	if (totalPixels <= maxSize) {
		return image.clone();
	}

	double scale = sqrt((double)maxSize / totalPixels);
	int newWidth = static_cast<int>(image.cols * scale);
	int newHeight = static_cast<int>(image.rows * scale);
	Mat resizedImage;
	resize(image, resizedImage, Size(newWidth, newHeight), INTER_AREA);
	return resizedImage;
}

// Automatically detect and correct the rotation of an image (Opencv and Tesseract)
Mat DocumentProcessor::combinedAutomaticRotation(Mat& image, char* dataPath)
{
	TesseractOCR ocr = TesseractOCR();
	DocumentScanner scanner = DocumentScanner();

	Mat imageClone = image.clone();
	imageClone = resizeBigImage(imageClone, 99999);

	//int rotationAngle1 = scanner.detectRotationAngle(imageClone);
	int rotationAngle1 = 0;
	int rotationAngle2 = ocr.detectRotationAngle(imageClone, dataPath);

	int totalRotationAngle = rotationAngle1 + rotationAngle2;
	if (totalRotationAngle >= 360) totalRotationAngle -= 360;

	return rotateImage(image, totalRotationAngle);
}

Coordinate DocumentProcessor::createCoordinate(double x, double y)
{
	Coordinate coordinate;
	coordinate.x = x;
	coordinate.y = y;
	return coordinate;
}

ScanFrameResult DocumentProcessor::createScanFrameResult(Coordinate topLeft, Coordinate topRight, Coordinate bottomLeft, Coordinate bottomRight, int outputBufferSize)
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

// Rotate an image by a specified angle (90, 180 or 270 degrees)
Mat DocumentProcessor::rotateImage(Mat& image, int angle)
{
	Mat result = image.clone();

	if (angle == 90) {
		rotate(result, result, ROTATE_90_CLOCKWISE);
	}
	else if (angle == 180) {
		rotate(result, result, ROTATE_180);
	}
	else if (angle == 270) {
		rotate(result, result, ROTATE_90_COUNTERCLOCKWISE);
	}

	return result;
}
