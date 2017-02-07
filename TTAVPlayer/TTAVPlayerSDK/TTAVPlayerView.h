//
//  TTAVPlayerView.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTPlayerOrientation) {
    TTPlayerOrientationPortrait,
    TTPlayerOrientationHomeLeft,
    TTPlayerOrientationHomeRight,
};

typedef NS_ENUM(NSInteger, TTAVPlayerType) {
    TTAVPlayerTypeDefault,
    TTAVPlayerTypeListPlayer,
    TTAVPlayerTypeLandscapePlayer,
};

@class TTVideoItem;
@interface TTAVPlayerView : UIView{
    CGFloat _rateValue;
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UIView *trainingView;
@property (weak, nonatomic) IBOutlet UIView *carrierView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UIButton *sweepBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@property (weak, nonatomic) IBOutlet UIButton *speedBtn;
@property (weak, nonatomic) IBOutlet UIButton *ratentBtn;
@property (weak, nonatomic) IBOutlet UIButton *modeBtn;

@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *slashView;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
@property (weak, nonatomic) IBOutlet UIImageView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sweepRight;
@property (weak, nonatomic) IBOutlet UILabel *tipsView;

@property (nonatomic, assign, readonly) BOOL isLock;    // 是否锁屏
@property (nonatomic, assign, readonly) BOOL isLoops;   // 是否单曲循环
@property (nonatomic, assign, readonly) BOOL isPlaying; // 是否正在播放
@property (nonatomic, assign, readonly) BOOL canPlay;   // 是否能播放

@property (nonatomic, assign) BOOL isLandscape;         // 是否横屏
@property (nonatomic, assign) BOOL isShowing;           // 控件是否在显示
@property (nonatomic, assign) BOOL paused;              // 是否暂停
@property (nonatomic, assign) BOOL isLeaved;            // 是否离开播放器

@property (nonatomic, assign) TTAVPlayerType type;
@property (nonatomic, copy) NSArray <TTVideoItem *>*itemArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) TTVideoItem   *item;

@property (nonatomic, assign, readonly) TTPlayerOrientation orientation;
@property (nonatomic, copy) void(^playerOrientationChanged)(TTPlayerOrientation orientation, BOOL isLandscape);
@property (nonatomic, copy) void(^clickPlayerFullScreen)();
@property (nonatomic, copy) void(^clickPlayerBackBlock)(TTPlayerOrientation fromOrientation);
@property (nonatomic, copy) void(^playerToStop)();

@property (nonatomic, copy) void(^didSelectIndex)(NSInteger index);

- (void)play;
- (void)pause;
- (void)stop;

- (void)close;

- (void)setPortraitLayout;
- (void)setLandscapeLayout;

@end
