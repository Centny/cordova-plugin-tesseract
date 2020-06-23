/********* Tesseract.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#undef fract1
#include <leptonica/allheaders.h>
#include <tesseract/baseapi.h>

@interface Tesseract : CDVPlugin {
  // Member variables go here.
}
@property(nonatomic) tesseract::TessBaseAPI *tess;
- (void)bootstrap:(CDVInvokedUrlCommand *)command;
- (void)recognize:(CDVInvokedUrlCommand *)command;
@end

@implementation Tesseract

- (void)bootstrap:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *result = nil;
  if (self.tess) {
    self.tess->End();
    self.tess = 0;
  }
  NSError *error;
  NSString *datapath, *language;
  if (command.arguments.count == 2) {
    datapath = [command.arguments objectAtIndex:0];
    language = [command.arguments objectAtIndex:1];
  } else {
    NSString *langs = @"";
#if TARGET_OS_OSX
    NSString *tessdata = [[NSBundle mainBundle].bundlePath
        stringByAppendingString:@"/Contents/Resources/tessdata"];
#else
    NSString *tessdata =
        [[NSBundle mainBundle].bundlePath stringByAppendingString:@"/tessdata"];
#endif
    NSLog(@"scanning langs by datapath:%@", tessdata);
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:tessdata error:&error];
    for (NSString *f in files) {
      if (![f hasSuffix:@".traineddata"]) {
        continue;
      }
      if (langs.length > 0) {
        langs = [langs stringByAppendingString:@"+"];
      }
      NSString *name = [f stringByReplacingOccurrencesOfString:@".traineddata"
                                                    withString:@""];
      langs = [langs stringByAppendingString:name];
    }
    datapath = tessdata;
    language = langs;
  }
  if (error) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:[error localizedDescription]];
  } else if (language.length < 1) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"traineddata not exists"];
  } else {
    tesseract::TessBaseAPI *tess = new tesseract::TessBaseAPI();
    if (tess->Init([datapath UTF8String], [language UTF8String])) {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                 messageAsString:@"init fail"];
      tess->End();
    } else {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                 messageAsString:@"ok"];
      self.tess = tess;
    }
  }
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)recognize:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *result = nil;
  if (!self.tess) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"not bootstrap"];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
    return;
  }
  if (command.arguments.count < 2 ||
      ![command.arguments[0] isKindOfClass:[NSString class]] ||
      ![command.arguments[1] isKindOfClass:[NSString class]]) {
    result =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                          messageAsString:@"type/image argument is required"];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
    return;
  }
  // Open input image with leptonica library
  NSString *type = command.arguments[0];
  NSString *data = command.arguments[1];
  NSData *img = [[NSData alloc] initWithBase64EncodedString:data options:0];
  Pix *image;
  if ([@"jpg" isEqualToString:type]) {
    image =
        pixReadMemJpeg((const l_uint8 *)[img bytes], img.length, 0, 0, 0, 0);
  } else {
    image = pixReadMemPng((const l_uint8 *)[img bytes], img.length);
  }
  if (image) {
    self.tess->SetImage(image);
    int left = 0, top = 0, width = 0, height = 0;
    if (command.arguments.count == 5) {
      if ([command.arguments[2] isKindOfClass:[NSNumber class]]) {
        left = [command.arguments[2] intValue];
      }
      if ([command.arguments[3] isKindOfClass:[NSNumber class]]) {
        top = [command.arguments[3] intValue];
      }
      if ([command.arguments[4] isKindOfClass:[NSNumber class]]) {
        width = [command.arguments[4] intValue];
      }
      if ([command.arguments[5] isKindOfClass:[NSNumber class]]) {
        height = [command.arguments[5] intValue];
      }
      self.tess->SetRectangle(left, top, width, height);
    }
    // Get OCR result
    char *outText = self.tess->GetUTF8Text();
    if (outText) {
      NSString *text = [NSString stringWithUTF8String:outText];
      delete[] outText;
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                 messageAsString:text];
    } else {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                 messageAsString:@"recognize fail"];
    }
    pixDestroy(&image);
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"wrap image fail"];
  }
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
@end
