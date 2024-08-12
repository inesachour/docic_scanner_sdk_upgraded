#include "tesseract_ocr.h"

TesseractOCR::TesseractOCR()
{}

// Preprocess an image for OCR
Mat TesseractOCR::preprocessImage(const Mat& image)
{
    Mat result;
    cvtColor(image, result, COLOR_BGR2GRAY);
    //adaptiveThreshold(result, result, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 11, 2);

    GaussianBlur(result, result, Size(3, 3), 0);
    GaussianBlur(result, result, Size(5, 5), 0);

    adaptiveThreshold(result, result, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY, 5, 2);
    return result;
}

// Extract text from an image using Tesseract OCR
string TesseractOCR::extractText(const Mat& image, char* dataPath)
{
    string outText;

    tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();

    //TRY OEM_TESSERACT_LSTM_COMBINED
    if (api->Init(dataPath, "eng+fra")) {
        return "";
    }

    Mat preprocessedImage = preprocessImage(image);
    api->SetVariable("tessedit_char_whitelist", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
    api->SetImage(preprocessedImage.data, preprocessedImage.cols, preprocessedImage.rows, preprocessedImage.channels(), preprocessedImage.step);

    api->Recognize(0);
    tesseract::ResultIterator* ri = api->GetIterator();
    tesseract::PageIteratorLevel level = tesseract::RIL_PARA;
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

    api->End();

    return outText;
}

// Detect the rotation angle of an image using Tesseract OCR (0, 90, 180 or 270)
int TesseractOCR::detectRotationAngle(const Mat& image, char* dataPath)
{
    tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();
    if (api->Init(dataPath, "eng+fra")) {
        std::cerr << "Could not initialize tesseract.\n";
        return 0;
    }

    Mat preprocessedImage = preprocessImage(image);
    api->SetPageSegMode(tesseract::PSM_AUTO_OSD);
    api->SetVariable("tessedit_char_whitelist", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
    api->SetImage(preprocessedImage.data, preprocessedImage.cols, preprocessedImage.rows, preprocessedImage.channels(), preprocessedImage.step);

    // Get the orientation information
    tesseract::PageIterator* it = api->AnalyseLayout();
    float deskew_angle;
    tesseract::Orientation orientation;
    tesseract::WritingDirection direction;
    tesseract::TextlineOrder order;
    if(it == NULL) {
        api->End();
        return 0;
    }
    it->Orientation(&orientation, &direction, &order, &deskew_angle);

    api->End();
    return static_cast<int>(orientation) * 90;
}
