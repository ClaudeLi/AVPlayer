//
//  TTPlayerViewController.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayerSDK.h"
#import "TTPlayerLandscapeController.h"

@interface TTPlayerViewController ()

@property (nonatomic, strong) TTAVPlayerView *playerView;
@property (nonatomic, strong) TTPlayerLandscapeController *landscapeViewController;

@end

@implementation TTPlayerViewController

- (instancetype)initWithType:(TTAVPlayerType)type{
    self = [super init];
    if (self) {
        self.playerView.type = type;
    }
    return self;
}

- (TTAVPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[TTAVPlayerView alloc] init];
        [_playerView setPortraitLayout];
    }
    return _playerView;
}

- (BOOL)isLeaved{
    return _playerView.isLeaved;
}

#pragma mark -
#pragma mark -- set方法 --
- (void)setType:(TTAVPlayerType)type{
    _type = type;
    self.playerView.type = type;
}

- (void)setFrame:(CGRect)frame{
    _frame = frame;
    self.view.frame = frame;
}

- (void)setParentView:(UIView *)parentView{
    _parentView = parentView;
    [_parentView.viewController addChildViewController:self];
    [_parentView addSubview:self.view];
}

- (void)setItem:(TTVideoItem *)item{
    _item = item;
    self.playerView.item = item;
}

- (void)setItemArray:(NSArray<TTVideoItem *> *)itemArray{
    _itemArray = itemArray;
    self.playerView.itemArray = _itemArray;
}

-(void)setIndex:(NSInteger)index{
    _index = index;
    self.playerView.index = _index;
}

#pragma mark -
#pragma mark -- viewDidLoad --
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.playerView];
    self.landscapeViewController = [[TTPlayerLandscapeController alloc] init];
    TT_WS(ws);
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view);
    }];
    
    [_playerView setPlayerOrientationChanged:^(TTPlayerOrientation orientation, BOOL isLandscape) {
        if (isLandscape) {
            [ws setLandscapeController:orientation];
        }else{
            [ws setPortraitController:orientation];
        }
    }];
    
    [_playerView setClickPlayerFullScreen:^{
        if (ws.playerView.orientation) {
            [ws setLandscapeController:ws.playerView.orientation];
        }else{
            [ws setLandscapeController:TTPlayerOrientationHomeRight];
        }
    }];
    
    [_playerView setClickPlayerBackBlock:^(TTPlayerOrientation fromOrientation) {
        [ws setPortraitController:fromOrientation];
    }];
    
    [_playerView setPlayerToStop:^{
        [ws setPortraitController:ws.playerView.orientation completion:^{
            if (ws.playerToStop) {
                ws.playerToStop();
            }
        }];
    }];
    
    [_playerView setDidSelectIndex:^(NSInteger index) {
        if (ws.didSelectIndex) {
            ws.didSelectIndex(index);
        }
    }];
}

#pragma mark -
#pragma mark -- 旋转 --
- (void)setLandscapeController:(TTPlayerOrientation)toOrientation{
    CGFloat angle = -M_PI_2;
    if (toOrientation == TTPlayerOrientationHomeRight) {
        angle = -M_PI_2;
    }else if (toOrientation == TTPlayerOrientationHomeLeft){
        angle = M_PI_2;
    }else{
        TTLog(@"toOrientation 错误");
        return;
    }
    if (_playerView.isLandscape) {
        TTLog(@"已经横屏");
        return;
    }
    if (self.presentedViewController == nil){
        _isFullScreen = YES;
        _parentView.viewController.view.hidden = YES;
        if (!_parentView.viewController.hidesBottomBarWhenPushed) {
            UITabBarController *tabBar = (UITabBarController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
            tabBar.tabBar.hidden = YES;
        }
        _landscapeViewController.orientation = toOrientation;
        [[UIApplication sharedApplication] keyWindow].backgroundColor = [UIColor blackColor];
        
        TT_WS(ws);
        [self presentViewController:_landscapeViewController animated:NO completion:^{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [self.landscapeViewController addChildViewController:self];
            [self.landscapeViewController.view addSubview:self.view];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
            [self.playerView setLandscapeLayout];
            
            ws.parentView.viewController.view.hidden = NO;
            //旋转前
            CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
            transform = CGAffineTransformScale(transform, 1.0, 1.0);
            ws.view.transform = transform;
            ws.view.center = _landscapeViewController.view.center;
            //旋转动画
            [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
                ws.view.transform = CGAffineTransformIdentity;
                ws.view.frame = _landscapeViewController.view.bounds;
            }completion:^(BOOL finished) {
                //            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }];
        }];
    }
}

- (void)setPortraitController:(TTPlayerOrientation)fromOrientation{
    [self setPortraitController:fromOrientation completion:nil];
}

- (void)setPortraitController:(TTPlayerOrientation)fromOrientation completion:(void(^)())completion{
    CGFloat angle = M_PI_2;
    if (fromOrientation == TTPlayerOrientationHomeLeft) {
        angle = -M_PI_2;
    }else if (fromOrientation == TTPlayerOrientationHomeRight){
        angle = M_PI_2;
    }else{
        TTLog(@"不需要改变方向");
        if (completion) {
            completion();
        }
        return;
    }
    if (!_playerView.isLandscape) {
        TTLog(@"已经竖屏");
        if (completion) {
            completion();
        }
        return;
    }
    if (!_parentView.viewController.hidesBottomBarWhenPushed) {
        UITabBarController *tabBar = (UITabBarController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        tabBar.tabBar.hidden = NO;
    }
    TT_WS(ws);
    [_landscapeViewController dismissViewControllerAnimated:NO completion:^{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self.parentView.viewController addChildViewController:self];
        [self.parentView addSubview:self.view];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        [self.playerView setPortraitLayout];
        //缩放动画
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        ws.view.transform = transform;
        ws.view.frame = _frame;
        ws.view.transform = CGAffineTransformRotate(transform, angle);
        
        [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]
                         animations:^{
                             ws.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             ws.view.frame = _frame;
                             ws.isFullScreen = NO;
                             if (completion) {
                                 completion();
                             }
                         }];
    }];
}

#pragma mark -
#pragma mark -- 暂停&关闭 --
- (void)pause{
    [_playerView pause];
}

- (void)paused{
    _playerView.paused = YES;
    [_playerView pause];
}

- (void)close{
    [self pause];
    [_playerView close];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
