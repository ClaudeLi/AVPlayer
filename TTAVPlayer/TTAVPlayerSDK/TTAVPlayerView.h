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

@interface TTAVPlayerView : UIView{
    CGFloat _rateValue;
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton   *lockBtn;
@property (weak, nonatomic) IBOutlet UIButton   *sweepBtn;
@property (weak, nonatomic) IBOutlet UIButton   *shareBtn;
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
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sweepRight;

@property (nonatomic, assign, readonly) BOOL isLock;
@property (nonatomic, assign, readonly) BOOL isLoops;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign, readonly) BOOL canPlay;

@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL paused;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSArray  *itemArray;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign, readonly) TTPlayerOrientation orientation;
@property (nonatomic, copy) void(^playerOrientationChanged)(TTPlayerOrientation orientation, BOOL isLandscape);
@property (nonatomic, copy) void(^clickPlayerFullScreen)();
@property (nonatomic, copy) void(^clickPlayerBackBlock)(TTPlayerOrientation fromOrientation);

- (void)play;
- (void)pause;

- (void)setPortraitLayout;
- (void)setLandscapeLayout;

@end
