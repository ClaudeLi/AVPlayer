//
//  NSString+TTPlayer.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/20.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "NSString+TTPlayer.h"

@implementation NSString (TTPlayer)

+ (NSString *)stringWithConvertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600.0 >= 1.0) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

@end
