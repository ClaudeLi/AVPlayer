//
//  TTPlayerManager.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/22.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define TTAVManager [TTPlayerManager playerManager]

@interface TTPlayerManager : NSObject

@property (nonatomic, assign) BOOL listPlayMode;
@property (nonatomic, assign) BOOL deauftPlayMode;

@property (nonatomic, assign) BOOL isAllowedToPlay;

@property (nonatomic, assign) BOOL isListRotate;

+ (TTPlayerManager *)playerManager;

@end
