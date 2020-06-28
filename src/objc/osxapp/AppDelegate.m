//
//  AppDelegate.m
//  osxapp
//
//  Created by Centny on 2020/6/28.
//

#import "AppDelegate.h"
#import <tessosx/tess.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    tess_shutdown(nil);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
