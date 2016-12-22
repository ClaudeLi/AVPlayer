//
//  TTAVPlayer.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/14.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TTAVPlayer : UIView

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) CGFloat rate;

@property (nonatomic, assign, readonly) BOOL canPlay;

- (void)play;
- (void)pause;
- (void)stop;

- (CGFloat)currentTime;
- (CGFloat)totalTime;
- (void)seekToTime:(float)seconds completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)setRate:(CGFloat)rate;

@property (nonatomic, copy) void (^playerLoadedTimeBlock)(CGFloat progress);
@property (nonatomic, copy) void (^playerCurrentTimeBlock)(CGFloat seconds);
@property (nonatomic, copy) void (^playerTotalTimeBlock)(CGFloat seconds);
@property (nonatomic, copy) void (^playerPlayEndBlock)();
@property (nonatomic, copy) void (^playerDirectionChange)();
@property (nonatomic, copy) void (^playerDelayPlay)(BOOL flag);
@property (nonatomic, copy) void (^playerToStop)();

@property (nonatomic, copy) void(^playerEnterForegroundBlock)();
@property (nonatomic, copy) void(^playerResignActiveBlock)();

- (void)removeNotifications;

@end
