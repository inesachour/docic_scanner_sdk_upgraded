cmake_minimum_required(VERSION 3.0.0)
project(docic_mobile_sdk)

include_directories(../include)

add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(lib_tesseract SHARED IMPORTED)
set_target_properties(lib_tesseract PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libtesseract.so)

add_library(lib_leptonica SHARED IMPORTED)
set_target_properties(lib_leptonica PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libleptonica.so)

add_library(docic_mobile_sdk SHARED ../cpp/document_scanner.cpp ../cpp/tesseract_ocr.cpp ../cpp/document_processor.cpp ../cpp/main.cpp)
target_link_libraries(docic_mobile_sdk lib_opencv lib_tesseract lib_leptonica)