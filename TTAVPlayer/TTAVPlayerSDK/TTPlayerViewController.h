//
//  TTPlayerViewController.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAVPlayerView.h"
@class TTVideoItem;
@interface TTPlayerViewController : UIViewController

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) TTAVPlayerType type;
@property (nonatomic, copy) NSArray <TTVideoItem *>*itemArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) TTVideoItem *item;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isLeaved;

@property (nonatomic, copy) void(^playerToStop)();
@property (nonatomic, copy) void(^didSelectIndex)(NSInteger index);

- (instancetype)initWithType:(TTAVPlayerType)type;

- (void)pause;

- (void)paused;

- (void)close;

@end
