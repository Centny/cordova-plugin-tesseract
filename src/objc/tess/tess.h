//
//  tess.h
//  tess
//
//  Created by Centny on 2020/6/28.
//  Copyright © 2020 Centny. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void *tess_bootstrap(NSString *datapath, NSString *language);
FOUNDATION_EXPORT void tess_shutdown(void *tess);
FOUNDATION_EXPORT NSString *tess_recognize(void *tess_, NSString **error, NSString *image, int x, int y, int w, int h);

// In this header, you should import all the public headers of your framework using statements like #import <tess/PublicHeader.h>
