//
//  tess.m
//  tess
//
//  Created by Centny on 2020/6/28.
//  Copyright © 2020 Centny. All rights reserved.
//

#import <Foundation/Foundation.h>
#undef fract1
#include <leptonica/allheaders.h>
#include <tesseract/baseapi.h>

FOUNDATION_EXPORT void *tess_bootstrap(NSString *datapath, NSString *language) {
  tesseract::TessBaseAPI *tess = new tesseract::TessBaseAPI();
  if (tess->Init([datapath UTF8String], [language UTF8String])) {
    tess->End();
    return NULL;
  }
  return tess;
}

FOUNDATION_EXPORT void tess_shutdown(void *tess_) {
  tesseract::TessBaseAPI *tess = (tesseract::TessBaseAPI *)tess_;
  if (tess) {
    tess->End();
  }
}

FOUNDATION_EXPORT NSString *tess_recognize(void *tess_, NSString **error,
                                           NSString *image, int x, int y, int w,
                                           int h) {
  tesseract::TessBaseAPI *tess = (tesseract::TessBaseAPI *)tess_;
  NSData *data = [[NSData alloc] initWithBase64EncodedString:image options:0];
  Pix *pix = pixReadMem((const l_uint8 *)[data bytes], data.length);
  if (pix) {
    tess->SetImage(pix);
    if (x > 0 || y > 0 || w > 0 || h > 0) {
      int width = pixGetWidth(pix);
      int height = pixGetHeight(pix);
      if (x < 0 || y < 0 || w < 1 || h < 1 || x > width || y > height ||
          x + w > width || y + h > height) {
        printf("error rectangle by width:%d,height:%d,x:%d,y:%d,w:%d,h:%d\n",
               width, height, x, y, w, h);
        *error = [NSString stringWithFormat:@"error rectangle"];
        return nil;
      }
      tess->SetRectangle(x, y, w, h);
    }
    char *otext = tess->GetUTF8Text();
    pixDestroy(&pix);
    if (*otext == 0) {
      *error = [NSString stringWithFormat:@"text not found"];
      return nil;
    }
    NSString *text = [NSString stringWithUTF8String:otext];
    delete[] otext;
    return text;
  } else {
    *error = [NSString stringWithFormat:@"wrap image fail"];
    return nil;
  }
}
