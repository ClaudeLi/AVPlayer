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
#import "UIDevice+TTDevice.h"
#import "TTAVPlayerGestureView.h"
#import "NSString+TTPlayer.h"
#import "TTPlayerManager.h"

@interface TTAVPlayerView ()

@property (nonatomic, assign) BOOL isSliding;
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

- (instancetype)init{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"TTAVPlayerView" owner:self options:nil] lastObject];
        [self insertSubview:self.gestureView atIndex:0];
        [self insertSubview:self.player atIndex:0];
        [self _initial];
        _modeBtn.selected = TTAVManager.playMode;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _player.frame    = self.bounds;
    _gestureView.frame = self.bounds;
}

#pragma mark -
#pragma mark -- setPlayerBlock --
- (void)setPlayerBlock{
    TT_WS(ws);
    //加载进度
    _player.playerLoadedTimeBlock = ^(CGFloat progress){
        [ws.bufferProgress setProgress:progress animated:YES];
    };
    //视屏总长
    _player.playerTotalTimeBlock = ^(CGFloat seconds){
        [ws updateTotalTime:seconds];
        if (!ws.paused) {
            [ws play];
        }
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
            [ws pause];
            TTLog(@"下一个");
        }
    };
    //关闭
    _player.playerToStop = ^{
    };
    //方向改变
    _player.playerDirectionChange = ^{
        if (!ws.isLock) {
            [ws setDeviceOrientation];
        }
    };
    //播放延迟
    _player.playerDelayPlay = ^(BOOL flag){
        if (flag) {
            [ws.loadingView startAnimating];
        }else{
            [ws.loadingView stopAnimating];
            [ws.loadingView setHidesWhenStopped:YES];
        }
    };
    // 前台
    _player.playerEnterForegroundBlock = ^{
        [ws play];
    };
    // 后台
    _player.playerResignActiveBlock = ^{
        [ws pause];
    };
}

- (void)setGestureViewBlock{
    TT_WS(ws);
    //单击/双击事件
    _gestureView.userTapGestureBlock = ^(NSUInteger number){
        if (number == 1) {
            if (ws.isShowing) {
                [ws _hideBar];
            }else{
                [ws _showBar];
            }
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

- (void)updateTotalTime:(float)total{
    _playSlider.maximumValue = total;
    _totalLabel.text = [NSString stringWithConvertTime:total];
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
    if (self.canPlay) {
        if (self.isPlaying) {
            [self pause];
        }else{
            [self play];
        }
    }else{
        [self pause];
    }
}

#pragma mark -
#pragma mark - 开始/暂停
- (void)play{
    _paused = NO;
    _playBtn.selected = YES;
    [self.player play];
}

- (void)pause{
    _playBtn.selected = NO;
    [self.player pause];
    if ([self.loadingView isAnimating]) {
        [self.loadingView stopAnimating];
        [self.loadingView setHidesWhenStopped:YES];
    }
}

- (void)setDeviceOrientation{
    UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
    if (orient == UIDeviceOrientationPortrait) {
        TTPlayerOrientation orientation = _orientation;
        _orientation = TTPlayerOrientationPortrait;
        if (_isLandscape) {
            _isLandscape = NO;
            [self setChangedOrientation:orientation];
        }
    }else if(orient == UIDeviceOrientationLandscapeLeft){
        if (!_isLandscape) {
            _isLandscape = YES;
            _orientation = TTPlayerOrientationHomeRight;
            [self setChangedOrientation:_orientation];
        }
    }else if (orient == UIDeviceOrientationLandscapeRight){
        if (!_isLandscape) {
            _isLandscape = YES;
            _orientation = TTPlayerOrientationHomeLeft;
            [self setChangedOrientation:_orientation];
        }
    }
}

- (void)setChangedOrientation:(TTPlayerOrientation)orientation {
    if (self.playerOrientationChanged) {
        self.playerOrientationChanged(orientation, _isLandscape);
    }
}

#pragma mark -
#pragma mark -- Action --
// 返回
- (IBAction)clickBackBtnAction:(id)sender {
    if (_isLandscape) {
        if (self.clickPlayerBackBlock) {
            _isLandscape = NO;
            TTPlayerOrientation orientation = _orientation;
            _orientation = TTPlayerOrientationPortrait;
            
            if (self.isLock) {
                //        _lockBtn.selected = !_lockBtn.selected;
            }
            self.clickPlayerBackBlock(orientation);
        }
    }
}
// 扫一扫
- (IBAction)clickSweepAction:(id)sender {

}
// 锁屏
- (IBAction)clickLockAction:(id)sender {
    _lockBtn.selected = !_lockBtn.selected;
    [self _showBar];
}
// 分享
- (IBAction)clickShareAction:(id)sender {
    
}
// 旋转屏幕
- (IBAction)clickRotateBtnAction:(id)sender {
    if (!_isLandscape) {
        _lockBtn.selected = NO;
        if (self.clickPlayerFullScreen) {
            self.clickPlayerFullScreen();
        }
    }
}
// 旋转模式
- (IBAction)clickModeBtnAction:(id)sender {
    _modeBtn.selected = !_modeBtn.selected;
    TTAVManager.playMode = _modeBtn.selected;
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
#pragma mark -- set方法 --
- (void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    [self _clearVaules];
    self.player.urlString = _urlString;
    _player.rate = _rateValue;
    _paused = NO;
}

- (void)setItemArray:(NSArray *)itemArray{
    _itemArray = itemArray;
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
        self.urlString = _itemArray[_index];
    }
}

#pragma mark -
#pragma mark -- dealloc --
- (void)dealloc{
    TTLog(@"%s", __func__);
    if (_player) {
        [_player stop];
        [_player removeNotifications];
        [_player removeFromSuperview];
        _player = nil;
    }
    [self removeTimer];
}

@end
