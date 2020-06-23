#!/bin/bash
set -xe 
./gradlew build
mkdir -p ../deps/android/aar/
cp -f tesseract/build/outputs/aar/tesseract-*.aar ../deps/android/aar/
