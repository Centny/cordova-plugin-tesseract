#!/bin/bash
set -e
cd ./plugins/cordova-plugin-tesseract/
if [ ! -f deps/android/aar/tesseract-release.aar ]; then
    rm -rf deps
    cp -rf ../../deps ./
    cd android_bind
    ./gradlew assembleRelease
    cp -f tesseract/build/outputs/aar/tesseract-*.aar ../deps/android/aar/
    cd ../
fi
