//
//  TTLandscapePlayerController.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/1/10.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAVPlayerView.h"

@class TTVideoItem;
@interface TTLandscapePlayerController : UIViewController

@property (nonatomic, assign) TTAVPlayerType type;
@property (nonatomic, strong) TTVideoItem *item;
@property (nonatomic, copy) NSArray <TTVideoItem *>*itemArray;
@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithType:(TTAVPlayerType)type;

@end
