// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include "tessc.h"
#include <leptonica/allheaders.h>
#include <tesseract/baseapi.h>

void* tess_bootstrap(const char* datapath, const char* language) {
	tesseract::TessBaseAPI* tess = new tesseract::TessBaseAPI();
	if (tess->Init(datapath, language)) {
		tess->End();
		tess = 0;
	}
	return tess;
}

extern __declspec(dllexport) void tess_shutdown(void* tess_) {
	tesseract::TessBaseAPI* tess = (tesseract::TessBaseAPI*)tess_;
	tess->End();
}

int tess_recognize(void* tess_, uint8_t* buffer, uint8_t* image, size_t image_size, int x, int y, int w, int h) {
	tesseract::TessBaseAPI* tess = (tesseract::TessBaseAPI*)tess_;
	Pix* pix = pixReadMem(image, image_size);
	if (pix) {
		tess->SetImage(pix);
		if (x > 0 || y > 0 || w > 0 || h > 0) {
			int width = pixGetWidth(pix);
			int height = pixGetHeight(pix);
			if (x<0 || y<0 || w<1 || h<1 || x > width || y > height || x + w > width || y + h > height) {
				printf("error rectangle by width:%d,height:%d,x:%d,y:%d,w:%d,h:%d\n", width, height, x, y, w, h);
				return -3;
			}
			tess->SetRectangle(x, y, w, h);
		}
		char* out = tess->GetUTF8Text();
		pixDestroy(&pix);
		if (*out == 0) {
			return -1;
		}
		int outted = strlen(out);
		strcpy_s((char*)buffer, outted + 1, out);
		delete[] out;
		return outted;
	}
	else {
		return -2;
	}
}