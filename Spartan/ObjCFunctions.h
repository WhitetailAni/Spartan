//
//  UIApplicationSuspend.h
//  Spartan
//
//  Created by RealKGB on 6/6/23.
//

#ifndef ObjCFunctions_h
#define ObjCFunctions_h

#import <UIKit/UIKit.h>

@interface ObjCFunctions: NSObject

+ (void)suspendNow;
+ (id)initWebView:(CGRect)bounds file:(NSURL *)file;

@end

#endif /* ObjCFunctions_h */
