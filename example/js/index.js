/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function () {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function () {
        this.receivedEvent('deviceready');
    },

    // Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        console.log('Received Event: ' + id);
        this.testTesseract(receivedElement);
    },
    toDataURL: async function (src, format) {
        return new Promise((resolve, reject) => {
            var img = new Image();
            img.crossOrigin = 'Anonymous';
            img.onload = function () {
                var canvas = document.createElement('canvas');
                var ctx = canvas.getContext('2d');
                var dataURL;
                canvas.height = this.naturalHeight;
                canvas.width = this.naturalWidth;
                ctx.drawImage(this, 0, 0);
                dataURL = canvas.toDataURL(format);
                resolve(dataURL);
            };
            img.src = src;
        });
    },
    testTesseract: async function (info) {
        try {
            var begin = new Date().getTime();
            info.innerText = "Tesseract is starting";
            console.log(info.innerText);
            await cordova.plugins.Tesseract.bootstrap();
            var bootUsed = new Date().getTime();
            info.innerText = "Tesseract is recognizing";
            console.log(info.innerText);
            var data = await this.toDataURL("img/chi_sim.png", "png");
            data = data.replace("data:image/png;base64,", "");
            var text1 = await cordova.plugins.Tesseract.recognize(data);
            var textUsed1 = new Date().getTime();
            var text2 = await cordova.plugins.Tesseract.recognize(data, 100, 10, 1286, 648);
            var textUsed2 = new Date().getTime();
            info.innerText =
                "b used " + (bootUsed - begin) + "/" + (textUsed2 - begin) + "ms\n" +
                text1 + "1 used " + (textUsed1 - bootUsed) + "/" + (textUsed2 - begin) + "ms\n" +
                text2 + "2 used " + (textUsed2 - textUsed1) + "/" + (textUsed2 - begin) + "ms\n";
            console.log(info.innerText);
        } catch (e) {
            info.innerText = e + "";
            console.log(info.innerText);
        }
    },
};

app.initialize();