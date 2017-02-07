//
//  NSObject+TTKVO.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/1/12.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "NSObject+TTKVO.h"
#import <objc/runtime.h>

@implementation NSObject (TTKVO)

+ (void)load
{
    [self switchMethod];
}

// 交换后的方法
- (void)removeDasen:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    @try {
        [self removeDasen:observer forKeyPath:keyPath];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    } @finally {
    }
}

+ (void)switchMethod
{
    SEL removeSel = @selector(removeObserver:forKeyPath:);
    SEL myRemoveSel = @selector(removeDasen:forKeyPath:);
    
    Method systemRemoveMethod = class_getClassMethod([self class],removeSel);
    Method DasenRemoveMethod = class_getClassMethod([self class], myRemoveSel);
    
    method_exchangeImplementations(systemRemoveMethod, DasenRemoveMethod);
}

@end
