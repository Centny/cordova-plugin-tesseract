#!/bin/bash
set -xe
sys=$(uname)
cd ../
if [ "$1" == "clean" ]; then
    rm -rf cordova-plugin-tesseract-test
    cordova create cordova-plugin-tesseract-test com.github.centny.cordova.tess.test Test
fi
cd cordova-plugin-tesseract-test
if [ "$1" == "clean" ]; then
    if [ "$sys" == "Darwin" ]; then
        cordova platform add android
        cordova platform add ios
        cordova platform add osx
    else
        cordova platform add windows
    fi
else
    if [ -d plugins/cordova-plugin-tesseract ]; then
        cordova plugin remove cordova-plugin-tesseract
    fi
fi
cordova plugin add ../cordova-plugin-tesseract/
if [ ! -d deps ];then
    ln -s ~/deps ./
fi
cp -rf ../cordova-plugin-tesseract/example/* ./www/
if [ "$sys" == "Darwin" ]; then
    cordova prepare android
    cordova prepare ios
    cordova prepare osx
else
    cordova prepare windows
fi
