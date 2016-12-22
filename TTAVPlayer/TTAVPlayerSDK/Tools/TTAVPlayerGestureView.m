//
//  TTAVPlayerGestureView.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/16.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayerGestureView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TTAVPlayerSDK.h"

typedef NS_ENUM(NSUInteger, TTGestureDirection) {
    TTGestureDirectionLeftOrRight,
    TTGestureDirectionUpOrDown,
    TTGestureDirectionNone
};

@interface TTAVPlayerGestureView ()<UIGestureRecognizerDelegate>

//上下左右手势操作
@property (nonatomic, assign) TTGestureDirection direction;
@property (nonatomic, assign) CGPoint startPoint;   //手势触摸起始位置
@property (nonatomic, assign) CGFloat startVB;      //记录当前音量/亮度
@property (nonatomic, strong) MPVolumeView *volumeView;     //控制音量的view
@property (nonatomic, strong) UISlider *volumeViewSlider;   //控制音量
@property (nonatomic, assign) CGFloat currentRate;  //当期视频播放的进度

@end
@implementation TTAVPlayerGestureView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureAction];
    }
    return self;
}

- (void)addGestureAction{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *twoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureAction:)];
    twoTapGesture.numberOfTapsRequired = 2;
    twoTapGesture.delegate = self;
    [self addGestureRecognizer:twoTapGesture];
    
    [tapGesture requireGestureRecognizerToFail:twoTapGesture];//没有检测到双击才进行单击事件
}

- (void)userTapGestureAction:(UITapGestureRecognizer*)tap{
    if (self.userTapGestureBlock) {
        self.userTapGestureBlock(tap.numberOfTapsRequired);
    }
}

//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    TT_WS(weakSelf);
    //记录首次触摸坐标
    weakSelf.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (weakSelf.startPoint.x <= weakSelf.frame.size.width / 2.0) {
        //亮度
        weakSelf.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音量
        weakSelf.startVB = weakSelf.volumeViewSlider.value;
    }
    //方向置为无
    weakSelf.direction = TTGestureDirectionNone;
    
    if (self.touchesBeganWithPointBlock) {
        self.currentRate = self.touchesBeganWithPointBlock();
    }
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    TT_WS(weakSelf);
    if (weakSelf.direction == TTGestureDirectionLeftOrRight) {
        if (self.touchesEndWithPointBlock) {
            self.touchesEndWithPointBlock(self.currentRate);
        }
    }
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint panPoint = [touch locationInView:self];
    
    //得出手指在Button上移动的距离
    CGPoint point = CGPointMake(panPoint.x - self.startPoint.x, panPoint.y - self.startPoint.y);

    TT_WS(weakSelf);
    //分析出用户滑动的方向
    if (weakSelf.direction == TTGestureDirectionNone) {
        if (point.x >= 30 || point.x <= -30) {
            //进度
            weakSelf.direction = TTGestureDirectionLeftOrRight;
        } else if (point.y >= 30 || point.y <= -30) {
            //音量和亮度
            weakSelf.direction = TTGestureDirectionUpOrDown;
        }
    }
    
    if (weakSelf.direction == TTGestureDirectionNone) {
        return;
    } else if (weakSelf.direction == TTGestureDirectionUpOrDown) {
        //音量和亮度
        if (weakSelf.startPoint.x >= weakSelf.frame.size.width / 2.0) {
            //音量
            if (point.y < 0) {
                //增大音量
                [weakSelf.volumeViewSlider setValue:weakSelf.startVB + (-point.y / 30.0 / 10) animated:YES];
                if (weakSelf.startVB + (-point.y / 30 / 10) - weakSelf.volumeViewSlider.value >= 0.1) {
                    [weakSelf.volumeViewSlider setValue:0.1 animated:NO];
                    [weakSelf.volumeViewSlider setValue:weakSelf.startVB + (-point.y / 30.0 / 10) animated:YES];
                }
                
            } else {
                //减少音量
                [weakSelf.volumeViewSlider setValue:weakSelf.startVB - (point.y / 30.0 / 10) animated:YES];
            }
            
        } else{
            //调节亮度
            if (point.y < 0) {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:weakSelf.startVB + (-point.y / 30.0 / 10)];
            } else {
                //减少亮度
                [[UIScreen mainScreen] setBrightness:weakSelf.startVB - (point.y / 30.0 / 10)];
            }
        }
    } else if (weakSelf.direction == TTGestureDirectionLeftOrRight) {
        //取得前一个位置
        CGPoint previous = [touch previousLocationInView:self];
        CGFloat offset_x = panPoint.x - previous.x;
        if (offset_x > 0) {
            self.currentRate+=0.5;
            if (self.toucheMoveWithPointBlock) {
                self.toucheMoveWithPointBlock(self.currentRate, YES);
            }
        }else{
            self.currentRate-=0.5;
            if (self.toucheMoveWithPointBlock) {
                self.toucheMoveWithPointBlock(self.currentRate, NO);
            }
        }
    }
}

- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];

        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.volumeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width * 9.0 / 16.0);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    for (UIView *subView in self.subviews) {
        if ([touch.view isDescendantOfView:subView]) {
            return NO;
        }
    }
    return YES;
}


@end
