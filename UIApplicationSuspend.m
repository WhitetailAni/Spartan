//
//  UIApplicationSuspend.m
//  Spartan
//
//  Created by RealKGB on 6/6/23.
//

#import <UIKit/UIKit.h>

@interface UIApplicationSuspend: NSObject

+ (void)suspendNow;

@end

@implementation UIApplicationSuspend

+ (void)suspendNow {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
}

@end
