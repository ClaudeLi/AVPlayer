//
//  VideoPlayer.h
//  AVPlayer
//
//  Created by ClaudeLi on 16/4/13.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 *  手势类型
 */
typedef NS_ENUM(NSInteger, TouchPlayerViewMode) {
    /**
     *  轻触
     */
    TouchPlayerViewModeNone,
    /**
     *  横滑（快进&快退）
     */
    TouchPlayerViewModeHorizontal,
    /**
     *  未知
     */
    TouchPlayerViewModeUnknow,
};

@interface VideoPlayer : UIView
{
    TouchPlayerViewMode _touchMode;
}
/**
 *  AVPlayer播放器
 */
@property (nonatomic, strong) AVPlayer *player;
/**
 *  播放状态，YES为正在播放，NO为暂停
 */
@property (nonatomic, assign) BOOL isPlaying;
/**
 *  是否横屏，默认NO -> 竖屏
 */
@property (nonatomic, assign) BOOL isLandscape;
/**
 *  是否锁定屏幕
 */
@property (nonatomic, assign) BOOL isLockScreen;

/**
 *  传入视频地址
 *
 *  @param string 视频url
 */
- (void)updatePlayerWith:(NSURL *)url;

/**
 *  移除通知&KVO
 */
- (void)removeObserverAndNotification;

/**
 *  横屏Layout
 */
- (void)setlandscapeLayout;

/**
 *  竖屏Layout
 */
- (void)setPortraitLayout;

/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;

@end
