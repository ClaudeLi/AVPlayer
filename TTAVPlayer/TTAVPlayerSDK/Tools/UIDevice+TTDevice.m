//
//  UIDevice+TTDevice.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/15.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "UIDevice+TTDevice.h"

@implementation UIDevice (TTDevice)

//调用私有方法实现
+ (void)setOrientation:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[self currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}

+ (BOOL)isOrientationLandscape{
    //if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    } else {
        return NO;
    }
}


@end
