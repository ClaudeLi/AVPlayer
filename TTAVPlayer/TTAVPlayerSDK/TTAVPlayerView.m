//
//  TTAVPlayerView.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayerView.h"
#import "TTAVPlayerView+Layout.h"
#import "TTAVPlayerSDK.h"
#import "TTAVPlayer.h"
#import "TTAVPlayerGestureView.h"
#import "NSString+TTPlayer.h"
#import "TTPlayerManager.h"

@interface TTAVPlayerView ()<UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isBackground;    // 是否在后台
@property (nonatomic, assign) BOOL isShare;         // 是否点分享
@property (nonatomic, assign) BOOL isRotate;        // 是否允许转屏
@property (nonatomic, assign) BOOL isPlayed;        // 是否已经播放
@property (nonatomic, assign) BOOL isBack;          // 是否从其他页面返回
@property (nonatomic, assign) BOOL isSliding;       // 是否在滑动slider
@property (nonatomic, strong) TTAVPlayer *player;
@property (nonatomic, strong) TTAVPlayerGestureView *gestureView;

@end

@implementation TTAVPlayerView

- (TTAVPlayerGestureView *)gestureView{
    if (_gestureView == nil) {
        _gestureView = [[TTAVPlayerGestureView alloc] initWithFrame:CGRectZero];
        [self setGestureViewBlock];
    }
    return _gestureView;
}

- (TTAVPlayer *)player{
    if (!_player) {
        _player = [[TTAVPlayer alloc] initWithFrame:CGRectZero];
        [self setPlayerBlock];
    }
    return _player;
}

- (BOOL)isLoops{
    return self.modeBtn.selected;
}

- (BOOL)isPlaying{
    return self.playBtn.selected;
}

- (BOOL)canPlay{
    return self.player.canPlay;
}

- (BOOL)isLock{
    return self.lockBtn.selected;
}

- (BOOL)isLeaved{
    return !_isBack;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"TTAVPlayerView" owner:self options:nil] lastObject];
        [self insertSubview:self.player atIndex:0];
        [self.carrierView insertSubview:self.gestureView atIndex:0];
        [self _initial];
        _isBack = YES;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _player.frame    = self.bounds;
    _gestureView.frame = self.carrierView.bounds;
}

#pragma mark -
#pragma mark -- setPlayerBlock --
- (void)setPlayerBlock{
    TT_WS(ws);
    _player.playerReadyToPlay = ^{
        [ws play];
    };
    _player.playerToClosePlayer = ^{
        [ws pause];
        if (ws.playerToStop) {
            ws.playerToStop();
        }
    };
    //加载进度
    _player.playerLoadedTimeBlock = ^(CGFloat progress){
        [ws.bufferProgress setProgress:progress animated:YES];
    };
    //视屏总长
    _player.playerTotalTimeBlock = ^(CGFloat seconds){
        [ws updateTotalTime:seconds];
    };
    //当前时间
    _player.playerCurrentTimeBlock = ^(CGFloat seconds){
        if (!ws.isSliding) {
            [ws updateCurrentTime:seconds];
        }
    };
    //播放完
    _player.playerPlayEndBlock = ^{
        if (ws.isLoops) {
            [ws play];
        }else{
            if (ws.nextBtn.selected) {
                ws.index = ws.index + 1;
            }else{
                [ws pause];
            }
        }
    };
    //关闭
    _player.playerToStop = ^{
        [ws pause];
    };
    //方向改变
    _player.playerDirectionChange = ^{
        if (!ws.isBackground) {
            if (!ws.isLock) {
                [ws setDeviceOrientation];
            }
        }
    };
    //播放延迟
    _player.playerDelayPlay = ^(BOOL flag){
        if (flag) {
            ws.loadingView.hidden = NO;
        }else{
            ws.loadingView.hidden = YES;
        }
    };
    // 前台
    _player.playerEnterForegroundBlock = ^{
        ws.isBackground = NO;
        if (ws.isShare) {
            if (!ws.isBack) {
                ws.isBack = YES;
            }
        }
        if (!ws.paused && ws.isPlayed) {
            [ws play];
        }
    };
    // 后台
    _player.playerResignActiveBlock = ^{
        ws.isBackground = YES;
        [ws playToPause];
    };
    
    [_player setJumpToRecordTime:^(CGFloat time) {
        if (time < 0) {
            time = 0;
        }else if (time > ws.playSlider.maximumValue){
            time = ws.playSlider.maximumValue;
        }
        ws.playSlider.value = time;
        [ws.player seekToTime:time completionHandler:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws _showBar];
            [ws showTipsWithTime:time];
        });
    }];
    
    [_player setJumpToRecordIndex:^(NSInteger index) {
        if (index >= 0) {
            ws.index = index;
        }
    }];
}

- (void)setGestureViewBlock{
    TT_WS(ws);
    //单击/双击事件
    _gestureView.userTapGestureBlock = ^(NSUInteger number){
        if (number == 1) {
            [ws playerShowBar];
        }else if (number == 2){
            [ws setPlayState];
        }
    };
    //开始触摸
    _gestureView.touchesBeganWithPointBlock = ^CGFloat(){
        //返回当前播放进度
        return ws.playSlider.value;
    };
    _gestureView.toucheMoveWithPointBlock = ^(CGFloat value, BOOL isFast){
        if (ws.canPlay) {
            [ws _showBar:NO];
            ws.isSliding = YES;
            ws.playSlider.value = value;
            [ws setCurrentTimeText];
        }
    };
    //结束触摸
    _gestureView.touchesEndWithPointBlock = ^(CGFloat value){
        CGFloat time = value;
        if (ws.canPlay) {
            if (time < 0) {
                time = 0;
            }else if (time > ws.playSlider.maximumValue){
                time = ws.playSlider.maximumValue;
            }
            ws.playSlider.value = time;
            [ws.player seekToTime:time completionHandler:^(BOOL finished) {
                ws.isSliding = NO;
            }];
        }
    };
}

- (void)playerShowBar{
    if (self.isShowing) {
        [self _hideBar];
    }else{
        [self _showBar];
    }
}

- (void)updateTotalTime:(float)total{
    if (total > _playSlider.minimumValue) {
        _playSlider.maximumValue = total;
        _totalLabel.text = [NSString stringWithConvertTime:total];
    }
}

- (void)updateCurrentTime:(float)currentTime{
    _playSlider.value = currentTime;
    _currentLabel.text = [NSString stringWithConvertTime:currentTime];
}

- (void)setPortraitLayout{
    _orientation = TTPlayerOrientationPortrait;
    [self _setPortraitLayout];
}

- (void)setLandscapeLayout{
    if (!_orientation) {
        _orientation = TTPlayerOrientationHomeRight;
    }
    [self _setLandscapeLayout];
}

- (void)setCurrentTimeText{
    CMTime dragedCMTime = CMTimeMake(_playSlider.value, 1);
    _currentLabel.text = [NSString stringWithConvertTime:CMTimeGetSeconds(dragedCMTime)];
}

- (void)setPlayState{
    if (self.isPlaying) {
        [self pause];
    }else{
        [self play];
    }
}

#pragma mark -
#pragma mark - 开始/暂停
- (void)play{
    _paused = NO;
    _isPlayed = YES;
    _playBtn.selected = YES;
    _stopBtn.hidden = YES;
    [self.player play];
    _player.rate = _rateValue;
}

- (void)playToPause{
    _playBtn.selected = NO;
    _stopBtn.hidden = NO;
    [self.player pause];
    if (!self.loadingView.hidden) {
        self.loadingView.hidden = YES;
    }
}

- (void)pause{
    _isPlayed = NO;
    [self playToPause];
}

- (void)close{
    [_player close];
}

- (void)stop{
    [self pause];
    [self.player stop];
}

- (void)setDeviceOrientation{
    UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
    if (orient == UIDeviceOrientationPortrait) {
        if (self.canPlay && _isRotate) {
            if (self.isLock || !_isBack) {
                return;
            }
            TTPlayerOrientation orientation = _orientation;
            _orientation = TTPlayerOrientationPortrait;
            if (_isLandscape) {
                self.clickPlayerBackBlock(orientation);
            }
        }
    }else if(orient == UIDeviceOrientationLandscapeLeft){
        _orientation = TTPlayerOrientationHomeRight;
        if (self.canPlay && _isRotate) {
            if (!_isLandscape && _isBack) {
                if (self.clickPlayerFullScreen) {
                    self.clickPlayerFullScreen();
                }
            }
        }
    }else if (orient == UIDeviceOrientationLandscapeRight){
        _orientation = TTPlayerOrientationHomeLeft;
        if (self.canPlay && _isRotate) {
            if (!_isLandscape && _isBack) {
                if (self.clickPlayerFullScreen) {
                    self.clickPlayerFullScreen();
                }
            }
        }
    }
    TTLog(@"%ld", (long)orient);
}

- (void)setChangedOrientation:(TTPlayerOrientation)orientation {
    if (self.playerOrientationChanged) {
        self.playerOrientationChanged(orientation, _isLandscape);
    }
}

#pragma mark -
#pragma mark -- Action --

- (void)tapFinishAction{
    if (self.clickPlayerBackBlock) {
        self.clickPlayerBackBlock(_orientation);
    }
}

// 返回
- (IBAction)clickBackBtnAction:(id)sender {
    if (_type == TTAVPlayerTypeLandscapePlayer) {
        if (self.clickPlayerBackBlock) {
            self.clickPlayerBackBlock(_orientation);
        }
    }else{
        if (_isLandscape) {
            if (self.clickPlayerBackBlock) {
                TTPlayerOrientation orientation = _orientation;
                _orientation = TTPlayerOrientationPortrait;
                if (self.isLock) {
                    _lockBtn.selected = !_lockBtn.selected;
                }
                self.clickPlayerBackBlock(orientation);
            }
        }
    }
}
// 扫一扫
- (IBAction)clickSweepAction:(id)sender {
    TTLog(@"投屏");
}
// 锁屏
- (IBAction)clickLockAction:(id)sender {
    _lockBtn.selected = !_lockBtn.selected;
    [self _showBar];
}
// 分享
- (IBAction)clickShareAction:(id)sender {
    TTLog(@"分享");
}

// 旋转屏幕
- (IBAction)clickRotateBtnAction:(id)sender {
    if (!_isLandscape) {
        if (_type == TTAVPlayerTypeListPlayer) {
            if (!TTAVManager.isListRotate) {
                TTAVManager.isListRotate = YES;
                _isRotate = TTAVManager.isListRotate;
            }
        }
        _lockBtn.selected = NO;
        if (self.clickPlayerFullScreen) {
            self.clickPlayerFullScreen();
        }
    }
}
// 旋转模式
- (IBAction)clickModeBtnAction:(id)sender {
    _modeBtn.selected = !_modeBtn.selected;
    if (_type == TTAVPlayerTypeListPlayer) {
        TTAVManager.listPlayMode = _modeBtn.selected;
    }else{
        TTAVManager.deauftPlayMode = _modeBtn.selected;
    }
    [self _showBar];
}
// 播放速率
- (IBAction)clickSpeedBtnAction:(id)sender {
    if (_rateValue == 1.0f) {
        [_speedBtn setTitle:@"0.8X"forState:UIControlStateNormal];
        _rateValue = 0.8f;
    } else if (_rateValue == 0.8f){
        [_speedBtn setTitle:@"0.6X"forState:UIControlStateNormal];
        _rateValue = 0.6f;
    } else if (_rateValue == 0.6f){
        [_speedBtn setTitle:@"0.4X"forState:UIControlStateNormal];
        _rateValue = 0.4f;
    } else if (_rateValue == 0.4f){
        [_speedBtn setTitle:@"1.0X"forState:UIControlStateNormal];
        _rateValue = 1.0f;
    }
    _player.rate = _rateValue;
    [self _showBar];
}
// 镜面
- (IBAction)clickRatentBtnAction:(id)sender {
    if (_ratentBtn.selected) {
        _player.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0);
    } else {
        _player.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    }
    _ratentBtn.selected = !_ratentBtn.selected;
    [self _showBar];
}
// 上一个
- (IBAction)clickLastBtnAction:(id)sender {
    if (_lastBtn.selected) {
        self.index = _index - 1;
    }
    [self _showBar];
}
// 下一个
- (IBAction)clickNextBtnAction:(id)sender {
    if (_nextBtn.selected) {
        self.index = _index + 1;
    }
    [self _showBar];
}
// 播放/暂停
- (IBAction)clickPlayBtnAction:(id)sender {
    [self setPlayState];
    [self _showBar];
}

// 按动滑块
- (IBAction)slideDidBegin:(id)sender {
    if (self.canPlay) {
        self.isSliding = YES;
    }
    [self _showBar:NO];
}
// 释放滑块
- (IBAction)slideDidEnd:(id)sender {
    [_player seekToTime:_playSlider.value completionHandler:^(BOOL finished) {
        self.isSliding = NO;
        [self play];
    }];
    [self _showBar];
}
// 滑动
- (IBAction)slideChanged:(id)sender {
    if (self.canPlay) {
        self.isSliding = YES;
        [self setCurrentTimeText];
    }
}

#pragma mark -
#pragma mark - set方法 -
- (void)setType:(TTAVPlayerType)type{
    _type = type;
    if (_type == TTAVPlayerTypeLandscapePlayer) {
        [self setLandscapeLayout];
        _modeBtn.selected = TTAVManager.deauftPlayMode;
        _isRotate = NO;
    }else if (_type == TTAVPlayerTypeListPlayer){
        _modeBtn.selected = TTAVManager.listPlayMode;
        _isRotate = TTAVManager.isListRotate;
    }else{
        _modeBtn.selected = TTAVManager.deauftPlayMode;
        _isRotate = YES;
    }
}

- (void)setItem:(TTVideoItem *)item{
    _item = item;
    [self playItem];
}

- (void)playItem{
    [self _clearVaules];
    self.player.videoItem = _item;
    _player.rate = _rateValue;
    self.titleLabel.text = _item.title;
    [self _showBar];
}

- (void)setItemArray:(NSArray<TTVideoItem *> *)itemArray{
    _itemArray = itemArray;
    self.player.itemArray = _itemArray;
}

- (void)setIndex:(NSInteger)index{
    _index = index;
    if (_itemArray.count > 1) {
        if (_index == 0) {
            _lastBtn.selected = NO;
            _nextBtn.selected = YES;
        }else if (_index == _itemArray.count - 1){
            _lastBtn.selected = YES;
            _nextBtn.selected = NO;
        }else{
            _lastBtn.selected = YES;
            _nextBtn.selected = YES;
        }
    }else{
        _lastBtn.selected = NO;
        _nextBtn.selected = NO;
    }
    TTLog(@"_index = %ld", (long)_index);
    if (_index < _itemArray.count) {
        if (self.didSelectIndex) {
            self.didSelectIndex(_index);
        }
        self.player.index = _index;
        self.item = _itemArray[_index];
    }
}

#pragma mark -
#pragma mark -- dealloc --
- (void)dealloc{
    TTLog(@"%s", __func__);
    if (_player) {
        [_player cancleLoading];
    }
    [self removeTimer];
}

@end
