#include "document_scanner.h"
#include "tesseract_ocr.h"

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

struct ScanFrameResult {
	DetectedCorners corners;
	int outputBufferSize;
};

class DocumentProcessor {
public:
	DocumentProcessor();
	static int processImage(char* path, char* dataPath, uchar** encodedOutput);
	static ScanFrameResult processFrame(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel, bool isDocumentDetected, char* dataPath, uchar** encodedOutput);
	static Mat convertYUVtoRGB(uint8_t* y, uint8_t* u, uint8_t* v, int height, int width, int bytesPerRow, int bytesPerPixel);
	static Mat resizeBigImage(const Mat& image, int maxSize);
	static Mat combinedAutomaticRotation(Mat& image, char* dataPath);
	static struct Coordinate createCoordinate(double x, double y);
	static struct ScanFrameResult createScanFrameResult(Coordinate topLeft, Coordinate topRight, Coordinate bottomLeft, Coordinate bottomRight, int detectedDocumentSize);
	static Mat rotateImage(Mat& image, int angle);
};