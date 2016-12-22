//
//  UIDevice+TTDevice.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/15.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (TTDevice)

/**
 *  切换横竖屏
 *
 *  @param orientation ：UIInterfaceOrientation
 */
+ (void)setOrientation:(UIInterfaceOrientation)orientation;

/**
 *  判断是否竖屏
 *
 *  @return 布尔值
 */
+ (BOOL)isOrientationLandscape;

@end
