//
//  TTPlayerManager.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/22.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTPlayerManager.h"

static TTPlayerManager *manager;
@implementation TTPlayerManager

+ (TTPlayerManager *)playerManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTPlayerManager alloc] init];
        manager.listPlayMode = YES;
        manager.deauftPlayMode = NO;
    });
    return manager;
}

@end
