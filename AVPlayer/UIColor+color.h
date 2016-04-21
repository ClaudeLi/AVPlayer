//
//  UIColor+color.h
//  Block
//
//  Created by ClaudeLi on 16/3/23.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (color)
// 随机色
+ (UIColor *)randomColor;

// 6位字符串颜色
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end
