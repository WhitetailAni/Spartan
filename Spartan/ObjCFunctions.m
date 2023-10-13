//
//  UIApplicationSuspend.m
//  Spartan
//
//  Created by RealKGB on 6/6/23.
//

#import <UIKit/UIKit.h>

@interface ObjCFunctions: NSObject

+ (void)suspendNow;

@end

@implementation ObjCFunctions

+ (void)suspendNow {
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

@end
