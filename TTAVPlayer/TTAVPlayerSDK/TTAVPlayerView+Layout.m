//
//  TTAVPlayerView+Layout.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayerView+Layout.h"
#import "TTAVPlayerSDK.h"
#import "NSString+TTPlayer.h"

@implementation TTAVPlayerView (Layout)


- (void)_initial{
    _rateValue = 1.0f;
    self.playSlider.minimumTrackTintColor = TTColor_MinimumColor;
    [self.ratentBtn setTitle:@"已镜像" forState:UIControlStateSelected];
    [self.ratentBtn setTitle:@"未镜像" forState:UIControlStateNormal];
    [self.ratentBtn setTitleColor:TTColor_TitleColor forState:UIControlStateNormal];
    [self.lockBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_unLock"] forState:UIControlStateNormal];
    [self.lockBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_lock"] forState:UIControlStateSelected];
    [self.lastBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_unLast"] forState:UIControlStateNormal];
    [self.lastBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_last"] forState:UIControlStateSelected];
    [self.nextBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_unNext"] forState:UIControlStateNormal];
    [self.nextBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_next"] forState:UIControlStateSelected];
    [self.modeBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_singleOne"] forState:UIControlStateSelected];
    [self.modeBtn setImage:[UIImage imageNamed:@"TTPlayerIcon_big_loops"] forState:UIControlStateNormal];
    
    CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    monkeyAnimation.toValue = [NSNumber numberWithFloat:2.0 * M_PI];
    monkeyAnimation.duration = 1.5f;
    monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    monkeyAnimation.removedOnCompletion = NO; //No Remove
    monkeyAnimation.repeatCount = FLT_MAX;
    [self.loadingView.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
    self.loadingView.layer.speed = 1.5f;
    
    self.tipsView.layer.masksToBounds = YES;
    self.tipsView.layer.cornerRadius = 4.0f;
}

- (void)_setPortraitLayout{
    self.isLandscape = NO;
    [self setSwitchLayoutHidden:YES];
    TT_WS(ws);
    self.airPlayRight.constant = 10.0f;
    self.bottomViewHeight.constant = 30.0f;
    self.timeLabelLeft.constant = 35.0f;
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.bottomView.mas_top);
        make.left.equalTo(ws.bottomView.mas_left).offset(5);
        make.bottom.equalTo(ws.bottomView.mas_bottom);
        make.width.mas_equalTo(30);
    }];
    [self.totalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.bottomView.mas_top);
        make.right.equalTo(ws.rotateBtn.mas_left);
        make.bottom.equalTo(ws.bottomView.mas_bottom);
    }];
    
    [self.playSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.carrierView).with.offset(75);
        make.right.equalTo(ws.carrierView).with.offset(-75);
        make.centerY.equalTo(ws.bottomView.mas_centerY);
        make.height.mas_equalTo(10);
    }];
    [self.bufferProgress mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.playSlider.mas_left);
        make.right.equalTo(ws.playSlider.mas_right);
        make.centerY.equalTo(ws.playSlider.mas_centerY).with.offset(1);
    }];
    [self _showBar];
}

- (void)_setLandscapeLayout{
    self.isLandscape = YES;
    [self setSwitchLayoutHidden:NO];
    TT_WS(ws);
    self.airPlayRight.constant = 110.0f;
    self.bottomViewHeight.constant = 44.0f;
    self.timeLabelLeft.constant = 15.0f;
    [self.totalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.bottomView.mas_top);
        make.left.equalTo(ws.slashView.mas_right);
        make.bottom.equalTo(ws.bottomView.mas_bottom);
    }];
    
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.bottomView.mas_top);
        make.bottom.equalTo(ws.bottomView.mas_bottom);
        make.centerX.equalTo(ws.bottomView.mas_centerX);
        make.width.mas_equalTo(50);
    }];
    
    [self.playSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.carrierView);
        make.right.equalTo(ws.carrierView);
        make.centerY.equalTo(ws.bottomView.mas_top);
        make.height.mas_equalTo(10);
    }];
    [self.bufferProgress mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.playSlider.mas_left);
        make.right.equalTo(ws.playSlider.mas_right);
        make.centerY.equalTo(ws.playSlider.mas_centerY).with.offset(1);
    }];
    [self _showBar];
}

- (void)setSwitchLayoutHidden:(BOOL)hidden{
    [[UIApplication sharedApplication] setStatusBarHidden:!hidden];
    
    self.rotateBtn.hidden = !hidden;
    self.topView.hidden     = hidden;
    self.speedBtn.hidden    = hidden;
    self.ratentBtn.hidden   = hidden;
    self.nextBtn.hidden     = hidden;
    self.lastBtn.hidden     = hidden;
    self.slashView.hidden  = hidden;
    self.modeBtn.hidden = hidden;
    
    NSString *thumbImage = hidden?@"TTPlayerIcon_small_point":@"TTPlayerIcon_big_point";
    NSString *playImage  = hidden?@"TTPlayerIcon_small_play":@"TTPlayerIcon_big_play";
    NSString *pauseImage  = hidden?@"TTPlayerIcon_small_pause":@"TTPlayerIcon_big_pause";
    [self.playSlider setThumbImage:[UIImage imageNamed:thumbImage] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:playImage] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:pauseImage] forState:UIControlStateSelected];
}


- (void)_clearVaules{
    self.playBtn.selected = NO;
    self.currentLabel.text = @"00:00";
    self.totalLabel.text = @"00:00";
    [self.bufferProgress setProgress:0];
    self.playSlider.value = 0.0;
    self.playSlider.maximumValue = 0.0;
}

- (void)_showBar{
    [self _showBar:YES];
}

- (void)_showBar:(BOOL)isReset{
    [self setBarHidden:NO];
    if (isReset) {
        [self removeTimer];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5]; //fireDate
        _timer = [[NSTimer alloc] initWithFireDate:date interval:1 target:self selector:@selector(_hideBar) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{
        [self removeTimer];
    }
}

- (void)_hideBar{
    [self setBarHidden:YES];
    [self removeTimer];
}

- (void)setBarHidden:(BOOL)hidden{
    if (self.isLandscape) {
        self.airPlayView.hidden = hidden;
        self.topView.hidden = hidden;
    }else{
        self.topView.hidden = YES;
        if (self.type == TTAVPlayerTypeListPlayer) {
            self.airPlayView.hidden = YES;
        }
    }
    self.bottomView.hidden = hidden;
    self.bufferProgress.hidden = hidden;
    self.playSlider.hidden = hidden;
    self.isShowing = !hidden;
}

- (void)removeTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)showTipsWithTime:(CGFloat)time{
    self.tipsView.hidden = NO;
    self.tipsView.text = [NSString stringWithFormat:@"上次观看至%@", [NSString stringWithConvertTime:time]];
    [self performSelector:@selector(hideTipsView) withObject:nil afterDelay:1.5];
}

- (void)hideTipsView{
    self.tipsView.hidden = YES;
}

@end
