cmake_minimum_required(VERSION 3.0.0)
project(docic_mobile_sdk)

include_directories(../include)

add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(docic_mobile_sdk SHARED ../cpp/main.cpp)
target_link_libraries(docic_mobile_sdk lib_opencv)