var exec = require('cordova/exec');

exports.bootstrap_ = function (success, error, datapath, language,) {
    var args = [];
    if (datapath && language) {
        args = [datapath, language];
    }
    exec(success, error, 'Tesseract', 'bootstrap', args);
};

exports.bootstrap = function (datapath, language,) {
    return new Promise((resolve, reject) => this.bootstrap_(resolve, reject, datapath, language));
};

exports.recognize_ = function (success, error, type, img, left, top, width, height) {
    var args = [type, img];
    if (typeof left == "number" && typeof top == "number" && typeof width == "number" && typeof height == "number") {
        args = [type, img, left, top, width, height];
    }
    exec(success, error, 'Tesseract', 'recognize', args);
};

exports.recognize = function (type, img, left, top, width, height) {
    return new Promise((resolve, reject) => this.recognize_(resolve, reject, type, img, left, top, width, height));
};