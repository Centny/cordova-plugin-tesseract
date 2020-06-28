var exec = require('cordova/exec');

exports.bootstrap_ = function (success, error, datapath, language,) {
    if (cordova.platformId == "windows") {
        if (datapath && language) {
            tessjs.Tesseract.bootstrap(datapath, language).then(success, error);
        } else {
            tessjs.Tesseract.bootstrap().then(success, error);
        }
        return;
    }
    var args = [];
    if (datapath && language) {
        args = [datapath, language];
    }
    exec(success, error, 'Tesseract', 'bootstrap', args);
};

exports.bootstrap = function (datapath, language,) {
    return new Promise((resolve, reject) => this.bootstrap_(resolve, reject, datapath, language));
};

exports.recognize_ = function (success, error, img, left, top, width, height) {
    if (cordova.platformId == "windows") {
        var onsuc = function (m) {
            var parts = m.split(",", 2);
            if (parts[0] == "0") {
                success(parts[1]);
            } else {
                error(parts[1]);
            }
        }
        if (typeof left == "number" && typeof top == "number" && typeof width == "number" && typeof height == "number") {
            tessjs.Tesseract.recognize(img, left, top, width, height).then(onsuc, error);
        } else {
            tessjs.Tesseract.recognize(img).then(onsuc, error);
        }
        return;
    }
    var args = [img];
    if (typeof left == "number" && typeof top == "number" && typeof width == "number" && typeof height == "number") {
        args = [img, left, top, width, height];
    }
    exec(success, error, 'Tesseract', 'recognize', args);
};

exports.recognize = function (img, left, top, width, height) {
    return new Promise((resolve, reject) => this.recognize_(resolve, reject, img, left, top, width, height));
};