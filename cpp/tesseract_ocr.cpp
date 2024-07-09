#include "tesseract_ocr.h"

TesseractOCR::TesseractOCR()
{}

string TesseractOCR::extractText(const char* imagePath)
{
	string outText;

	tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();
	
	//TRY OEM_TESSERACT_LSTM_COMBINED
	if (api->Init(NULL, "eng+ara+fra")) {
		return "";
	}

	Pix* image = pixRead(imagePath);
	api->SetImage(image);

	api->Recognize(0);
	tesseract::ResultIterator* ri = api->GetIterator();
	tesseract::PageIteratorLevel level = tesseract::RIL_WORD;
	if (ri != 0) {
		do {
			const char* word = ri->GetUTF8Text(level);
			float conf = ri->Confidence(level);
			if (conf >= 75.0) {
				int x1, y1, x2, y2;
				ri->BoundingBox(level, &x1, &y1, &x2, &y2);
				printf("word: '%s';  \tconf: %.2f; BoundingBox: %d,%d,%d,%d;\n",
					word, conf, x1, y1, x2, y2);
				outText += word;
				outText += " ";
			}
		} while (ri->Next(level));
	}
	
	//outText = api->GetUTF8Text();
	
	api->End();
	pixDestroy(&image);

	return outText;
}

int TesseractOCR::detectRotationAngle(const char* imagePath, const char* dataPath)
{
	Mat image = imread(imagePath);

	tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();
	if (api->Init(dataPath, "eng+ara+fra", tesseract::OEM_LSTM_ONLY)) {
		std::cerr << "Could not initialize tesseract.\n";
		return -55;
	}

	api->SetPageSegMode(tesseract::PSM_AUTO_OSD);
	api->SetImage(image.data, image.cols, image.rows, image.channels(), image.step);

	// Get the orientation information
	tesseract::PageIterator* it = api->AnalyseLayout();
	float deskew_angle;
	tesseract::Orientation orientation;
	tesseract::WritingDirection direction;
	tesseract::TextlineOrder order;
	it->Orientation(&orientation, &direction, &order, &deskew_angle);

	api->End();
	return static_cast<int>(orientation) * 90;
}
