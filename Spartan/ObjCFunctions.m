//
//  UIApplicationSuspend.m
//  Spartan
//
//  Created by RealKGB on 6/6/23.
//

#import <UIKit/UIKit.h>

@interface ObjCFunctions: NSObject

+ (void)suspendNow;
+ (id)initWebView:(CGRect)bounds file:(NSURL *)file;

@end

@implementation ObjCFunctions

+ (void)suspendNow {
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

+ (id)initWebView:(CGRect)bounds file:(NSURL *)file {
	id webview = [[NSClassFromString(@"UIWebView") alloc] init];
    
    [webview setTranslatesAutoresizingMaskIntoConstraints:false];
    [webview setClipsToBounds:false];

    [webview setFrame:bounds];
    [webview setDelegate:self];
    [webview setLayoutMargins:UIEdgeInsetsZero];
    [webview loadRequest:[NSURLRequest requestWithURL:file]];
    
    UIScrollView *scrollView = [webview scrollView];
    [scrollView setLayoutMargins:UIEdgeInsetsZero];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentOffset = CGPointZero;
    scrollView.contentInset = UIEdgeInsetsZero;
    scrollView.frame = bounds;
    scrollView.clipsToBounds = NO;
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    scrollView.panGestureRecognizer.allowedTouchTypes = @[ @(UITouchTypeIndirect) ];
    scrollView.scrollEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    
    [webview setUserInteractionEnabled:NO];

    return webview;
}

@end
