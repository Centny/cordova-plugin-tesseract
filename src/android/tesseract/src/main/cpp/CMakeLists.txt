# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             tesseract

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             tesseract.cpp )

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library(log-lib log)
find_library(z-lib z)

target_include_directories(tesseract PRIVATE
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/include
        )
#

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp -fPIC")

#if(${ANDROID_ABI} STREQUAL "x86")
#    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wall -v -Wl,--no-warn-shared-textrel")
#endif()

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.
target_link_libraries(tesseract PRIVATE
        -fopenmp -fPIC
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libjpeg.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/liblept.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libopenjp2.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libpng16.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libtesseract.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libtiff.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libturbojpeg.a
        ${CMAKE_SOURCE_DIR}/../../../../../../../deps/android/${ANDROID_ABI}/lib/libwebp.a
        ${log-lib} ${z-lib}
        )