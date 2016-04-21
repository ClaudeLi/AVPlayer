//
//  CLRotatingScreen.h
//  tiaooo
//
//  Created by ClaudeLi on 16/3/31.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CLRotatingScreen : NSObject

/**
 *  切换横竖屏
 *
 *  @param orientation ：UIInterfaceOrientation
 */
+ (void)forceOrientation: (UIInterfaceOrientation)orientation;

/**
 *  判断是否竖屏
 *
 *  @return 布尔值
 */
+ (BOOL)isOrientationLandscape;

@end
