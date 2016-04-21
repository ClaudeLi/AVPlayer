//
//  VideoPlayer.m
//  AVPlayer
//
//  Created by ClaudeLi on 16/4/13.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "VideoPlayer.h"
#import "CLRotatingScreen.h"
#import "NSString+time.h"

@interface VideoPlayer ()
{
    BOOL isIntoBackground;
    BOOL isShowToolbar;
    NSTimer *_timer;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    id _playTimeObserver; // 播放进度观察者
}
@property (weak, nonatomic) IBOutlet UIView *view;
/**
 *  _playerLayer所在的View
 */
@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn; //锁屏按钮

@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn; //播放按钮
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn; //转屏按钮
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playProgress; //播放进度
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress; //缓存进度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downHeight;
/**
 *  快进/快退
 */
@property (weak, nonatomic) IBOutlet UIView *speedView;
@property (weak, nonatomic) IBOutlet UIImageView *speedImage;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speedTopHeight;
@end

@implementation VideoPlayer

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"VideoPlayer" owner:self options:nil] firstObject];
        [self addSubview:self.view];
        [self.playProgress setThumbImage:[UIImage imageNamed:@"MoviePlayer_Slider"] forState:UIControlStateNormal];
        [self setPortraitLayout];
        self.player = [[AVPlayer alloc] init];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.playerView.layer addSublayer:_playerLayer];
        return self;
    }
    return nil;
}

// 后台
- (void)resignActiveNotification{
    NSLog(@"进入后台");
    isIntoBackground = YES;
    [self pause];
}

// 前台
- (void)enterForegroundNotification
{
    NSLog(@"回到前台");
    isIntoBackground = NO;
    [self play];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}

- (void)updatePlayerWith:(NSURL *)url{
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
    [self addObserverAndNotification];
}

- (void)addObserverAndNotification{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听缓冲进度
    [self monitoringPlayback:_playerItem];// 监听播放状态
    [self addNotification];
}

-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 后台&前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    _playerItem = [notification object];
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
}

#pragma mark - KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (isIntoBackground) {
            return;
        }else{
            if ([item status] == AVPlayerStatusReadyToPlay) {
                NSLog(@"AVPlayerStatusReadyToPlay");
                CMTime duration = item.duration;// 获取视频总长度
                NSLog(@"%f", CMTimeGetSeconds(duration));
                [self setMaxDuratuin:CMTimeGetSeconds(duration)];
                [self play];
            }else if([item status] == AVPlayerStatusFailed) {
                NSLog(@"AVPlayerStatusFailed");
            }else{
                NSLog(@"AVPlayerStatusUnknown");
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSTimeInterval timeInterval = [self availableDurationRanges];//缓冲进度
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.bufferProgress setProgress: timeInterval / totalDuration animated:YES];
    }
}

- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

//- (void)dealloc{
//    [self removeObserverAndNotification];
//}
#pragma mark - 移除通知&KVO
- (void)removeObserverAndNotification{
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMaxDuratuin:(float)total{
    self.playProgress.maximumValue = total;
    self.totalTimeLabel.text = [NSString convertTime:self.playProgress.maximumValue];
}

#pragma mark - _playTimeObserver
- (void)monitoringPlayback:(AVPlayerItem *)item {
    WS(ws);
    //这里设置每秒执行30次
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (_touchMode != TouchPlayerViewModeHorizontal) {
            // 计算当前在第几秒
            float currentPlayTime = (double)item.currentTime.value/item.currentTime.timescale;
            [ws updateVideoSlider:currentPlayTime];
        }else{
            return;
        }
    }];
}

- (void)updateVideoSlider:(float)currentTime{
    self.playProgress.value = currentTime;
    self.currentTimeLabel.text = [NSString convertTime:currentTime];
    self.speedLabel.text = [NSString stringWithFormat:@"%@/%@", [NSString convertTime:currentTime], [NSString convertTime:self.playProgress.maximumValue]];
}

- (void)setlandscapeLayout{
    self.isLandscape = YES;
    [self landscapeHide];
    self.downHeight.constant = 44.0f;
    self.speedTopHeight.constant = 80.0f;
    [self.rotateBtn setImage:[UIImage imageNamed:@"MoviePlayer_小屏"] forState:UIControlStateNormal];
}

- (void)setPortraitLayout{
    self.isLandscape = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self portraitHide];
    self.topView.hidden = YES;
    self.downHeight.constant = 32.0f;
    self.speedTopHeight.constant = 50.0f;
    [self.rotateBtn setImage:[UIImage imageNamed:@"MoviePlayer_Full"] forState:UIControlStateNormal];
}
- (IBAction)playOrStopAction:(id)sender {
    if (_isPlaying) {
        [self pause];
    }else{
        [self play];
    }
    [self chickToolBar];
}
- (IBAction)playerSliderDown:(id)sender {
    NSLog(@"按动暂停");
    [self pause];
}
- (IBAction)playerSliderInside:(id)sender {
     NSLog(@"释放播放");
    [self play];
}
- (IBAction)playerSliderChange:(id)sender {
    [self pause];
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(self.playProgress.value, 1);
    [_playerItem seekToTime:dragedCMTime];
    [self chickToolBar];
}

- (void)play{
    _isPlaying = YES;
    [_player play];
    [self.playBtn  setImage:[UIImage imageNamed:@"MoviePlayer_Play"] forState:UIControlStateNormal];
}

- (void)pause{
    _isPlaying = NO;
    [_player pause];
    [self.playBtn  setImage:[UIImage imageNamed:@"MoviePlayer_Stop"] forState:UIControlStateNormal];
}

- (IBAction)rotatingAction:(id)sender {
    [self chickToolBar];
    if (self.isLockScreen) {
        NSLog(@"已锁定屏幕,请点击右上角解锁");
    }else{
        if([CLRotatingScreen isOrientationLandscape]) {
            [CLRotatingScreen forceOrientation: UIInterfaceOrientationPortrait];
            [self setPortraitLayout];
        }else{
            [CLRotatingScreen forceOrientation: UIInterfaceOrientationLandscapeRight];
            [self setlandscapeLayout];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchBegan");
    _touchMode = TouchPlayerViewModeNone;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchEnd");
    if (_touchMode == TouchPlayerViewModeNone) {
        if (self.isLandscape) {
            if (isShowToolbar) {
                [self landscapeHide];
            }else{
                [self landscapeShow];
            }
        }else{
            if (isShowToolbar) {
                [self portraitHide];
            }else{
                [self portraitShow];
            }
        }
    }else{
        CMTime offsetTime = CMTimeMake(self.playProgress.value, 1);
        [_playerItem seekToTime:offsetTime];
        self.speedView.hidden = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touchMode = TouchPlayerViewModeHorizontal;
    
    UITouch *touch = [touches anyObject];
    //取得当前位置
    CGPoint currentLocation = [touch locationInView:self];
    //取得前一个位置
    CGPoint previous = [touch previousLocationInView:self];
    CGFloat offset_x = currentLocation.x - previous.x;
    if (offset_x == 0) {
        NSLog(@"return");
        return;
    }else{
        self.speedView.hidden = NO;
        if (offset_x > 0) {
            NSLog(@"横向向右");
            self.speedImage.image = [UIImage imageNamed:@"MoviePlayer_快进"];
            [self updateVideoSlider:self.playProgress.value+1];
        }else if(offset_x < 0){
            NSLog(@"横向向左");
            self.speedImage.image = [UIImage imageNamed:@"MoviePlayer_快退"];
            [self updateVideoSlider:self.playProgress.value-1];
        }
    }
}

- (void)portraitShow{
    isShowToolbar = YES;
    self.downView.hidden = NO;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5]; //fireDate
    [_timer invalidate];
    _timer = nil;
    _timer = [[NSTimer alloc] initWithFireDate:date interval: 1 target:self selector:@selector(portraitHide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)chickToolBar{
    if (self.isLandscape) {
        [self landscapeShow];
    }else{
        [self portraitShow];
    }
}

- (void)portraitHide{
    isShowToolbar = NO;
    self.downView.hidden = self.topView.hidden = YES;
}

- (void)landscapeShow{
    isShowToolbar = YES;
    self.topView.hidden = NO;
    self.downView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5]; //fireDate
    [_timer invalidate];
    _timer = nil;
    _timer = [[NSTimer alloc] initWithFireDate:date interval: 1 target:self selector:@selector(landscapeHide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)landscapeHide{
    isShowToolbar = NO;
     self.downView.hidden = self.topView.hidden = YES;
    if (self.isLandscape) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (IBAction)lockBtnAction:(id)sender {
    if (self.isLockScreen) {
        [self unlock];
    }else{
        [self lock];
    }
    [self chickToolBar];
}

- (void)lock{
    self.isLockScreen = YES;
    [self.lockBtn setImage:[UIImage imageNamed:@"MoviePlayer_已锁"] forState:UIControlStateNormal];
}

- (void)unlock{
    self.isLockScreen = NO;
    [self.lockBtn setImage:[UIImage imageNamed:@"MoviePlayer_锁屏"] forState:UIControlStateNormal];
}

@end
