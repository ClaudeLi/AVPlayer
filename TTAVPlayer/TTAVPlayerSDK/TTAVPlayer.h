//
//  TTAVPlayer.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/14.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TTAVPlayerView.h"

@class TTVideoItem;
@interface TTAVPlayer : UIView

@property (nonatomic, strong) TTVideoItem *videoItem;
@property (nonatomic, assign) CGFloat rate;

@property (nonatomic, assign, readonly) BOOL canPlay;

@property (nonatomic, copy) NSArray *itemArray;
@property (nonatomic, assign) NSInteger index;

- (void)play;
- (void)pause;
- (void)stop;

- (void)cancleLoading;

- (CGFloat)currentTime;
- (CGFloat)totalTime;
- (void)seekToTime:(float)seconds completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)setRate:(CGFloat)rate;

@property (nonatomic, copy) void (^playerLoadedTimeBlock)(CGFloat progress);
@property (nonatomic, copy) void (^playerCurrentTimeBlock)(CGFloat seconds);
@property (nonatomic, copy) void (^playerTotalTimeBlock)(CGFloat seconds);
@property (nonatomic, copy) void (^playerPlayEndBlock)();
@property (nonatomic, copy) void (^playerDirectionChange)();
@property (nonatomic, copy) void (^playerReadyToPlay)();
@property (nonatomic, copy) void (^playerDelayPlay)(BOOL flag);
@property (nonatomic, copy) void (^playerToStop)();
@property (nonatomic, copy) void (^playerToClosePlayer)();

@property (nonatomic, copy) void(^playerEnterForegroundBlock)();
@property (nonatomic, copy) void(^playerResignActiveBlock)();

// 做视频播放时间本地记录时使用,demo中未用到
@property (nonatomic, copy) void(^jumpToRecordTime)(CGFloat time);
@property (nonatomic, copy) void(^jumpToRecordIndex)(NSInteger index);

//- (void)removeNotifications;
- (void)close;

@end
