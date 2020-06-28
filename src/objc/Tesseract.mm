/********* Tesseract.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#if TARGET_OS_OSX
#import <tessosx/tess.h>
#else
#import <tessios/tess.h>
#endif

@interface Tesseract : CDVPlugin {
  // Member variables go here.
}
@property(nonatomic) void *tess;
- (void)bootstrap:(CDVInvokedUrlCommand *)command;
- (void)recognize:(CDVInvokedUrlCommand *)command;
@end

@implementation Tesseract

- (void)bootstrap:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *result = nil;
  if (self.tess) {
    tess_shutdown(self.tess);
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
    void *tess = tess_bootstrap(datapath, language);
    if (tess) {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                 messageAsString:@"ok"];
      self.tess = tess;
    } else {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                 messageAsString:@"init fail"];
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
  if (command.arguments.count < 1 ||
      ![command.arguments[0] isKindOfClass:[NSString class]]) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"image argument is required"];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
    return;
  }
  // Open input image with leptonica library
  NSString *image = command.arguments[0];
  int left = 0, top = 0, width = 0, height = 0;
  if (command.arguments.count == 5) {
    if ([command.arguments[1] isKindOfClass:[NSNumber class]]) {
      left = [command.arguments[1] intValue];
    }
    if ([command.arguments[2] isKindOfClass:[NSNumber class]]) {
      top = [command.arguments[2] intValue];
    }
    if ([command.arguments[3] isKindOfClass:[NSNumber class]]) {
      width = [command.arguments[3] intValue];
    }
    if ([command.arguments[4] isKindOfClass:[NSNumber class]]) {
      height = [command.arguments[4] intValue];
    }
  }
  NSString *error;
  NSString *text;
  text = tess_recognize(self.tess, &error, image, left, top, width, height);
  if (text) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                               messageAsString:text];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:error];
  }
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
@end
