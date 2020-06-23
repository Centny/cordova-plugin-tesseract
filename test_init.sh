#!/bin/bash
set -xe
cd ../
if [ "$1" == "clean" ]; then
    rm -rf cordova-plugin-tesseract-test
    cordova create cordova-plugin-tesseract-test com.github.centny.cordova.tess.test Test
fi
cd cordova-plugin-tesseract-test
if [ "$1" == "clean" ]; then
    cordova platform add android
    cordova platform add ios
    cordova platform add osx
else
    cordova plugin remove cordova-plugin-tesseract
fi
cordova plugin add ../cordova-plugin-tesseract/
# cp -rf ../cordova-plugin-tesseract/example/* ./www/
# cp -rf /usr/local/share/tessdata ./
# echo v1.0.0 >tessdata/version.txt
# cp -rf tessdata platforms/android/app/src/main/assets/
# cp -rf tessdata platforms/ios/Test/
# cp -rf tessdata platforms/osx/Test/
# ln -s ~/deps ./
# cordova prepare android
# cordova prepare ios
# cordova prepare osx
