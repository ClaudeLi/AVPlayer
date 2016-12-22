//
//  TTPlayerViewController.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayerSDK.h"
#import "TTPlayerLandscapeController.h"

@interface TTPlayerViewController (){
    TTPlayerLandscapeController *landscapeViewController;
}

@property (nonatomic, strong) TTAVPlayerView *playerView;

@end

@implementation TTPlayerViewController

- (TTAVPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[TTAVPlayerView alloc] init];
        [_playerView setPortraitLayout];
    }
    return _playerView;
}

#pragma mark -
#pragma mark -- set方法 --
- (void)setFrame:(CGRect)frame{
    _frame = frame;
    self.view.frame = frame;
}

- (void)setParentView:(UIView *)parentView{
    _parentView = parentView;
    [_parentView.viewController addChildViewController:self];
    [_parentView addSubview:self.view];
}

-(void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    self.playerView.urlString = urlString;
}

- (void)setItemArray:(NSArray *)itemArray{
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
    landscapeViewController = [[TTPlayerLandscapeController alloc] init];
    TT_WS(ws);
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
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
    _isFullScreen = YES;
    landscapeViewController.orientation = toOrientation;
    [_parentView.viewController presentViewController:landscapeViewController animated:NO completion:^{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [landscapeViewController addChildViewController:self];
        [landscapeViewController.view addSubview:self.view];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.playerView setLandscapeLayout];
        
        //旋转前
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        transform = CGAffineTransformScale(transform, 1.0, 1.0);
        self.view.transform = transform;
        self.view.center = landscapeViewController.view.center;
        //旋转动画
        [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
            self.view.transform = CGAffineTransformIdentity;
            self.view.frame = landscapeViewController.view.bounds;
        }completion:^(BOOL finished) {
//            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }];
    }];
}

- (void)setPortraitController:(TTPlayerOrientation)fromOrientation{
    CGFloat angle = M_PI_2;
    if (fromOrientation == TTPlayerOrientationHomeLeft) {
        angle = -M_PI_2;
    }else if (fromOrientation == TTPlayerOrientationHomeRight){
        angle = M_PI_2;
    }else{
        TTLog(@"fromOrientation == %ld", fromOrientation);
        return;
    }
    [landscapeViewController dismissViewControllerAnimated:NO completion:^{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [_parentView.viewController addChildViewController:self];
        [_parentView addSubview:self.view];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.playerView setPortraitLayout];
        //缩放动画
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.view.transform = transform;
        self.view.frame = _frame;
        self.view.transform = CGAffineTransformRotate(transform, angle);
        
        [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]
                         animations:^{
                             self.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             self.view.frame = _frame;
                         }];
    }];
}

#pragma mark - 
#pragma mark -- 暂停&关闭 --
- (void)pause{
    _playerView.paused = YES;
    [_playerView pause];
}

- (void)close{
    [self pause];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
