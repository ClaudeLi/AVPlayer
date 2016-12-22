//
//  TTPlayerManager.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/22.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TTAVManager [TTPlayerManager playerManager]

@interface TTPlayerManager : NSObject

@property (nonatomic, assign) BOOL playMode;

+ (TTPlayerManager *)playerManager;

@end
