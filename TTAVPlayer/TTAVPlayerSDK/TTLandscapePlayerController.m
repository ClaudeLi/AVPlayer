//
//  TTLandscapePlayerController.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/1/10.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTLandscapePlayerController.h"
#import "TTAVPlayerSDK.h"

@interface TTLandscapePlayerController ()

@property (nonatomic, strong) TTAVPlayerView *playerView;

@end

@implementation TTLandscapePlayerController

- (instancetype)initWithType:(TTAVPlayerType)type{
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (TTAVPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[TTAVPlayerView alloc] init];
    }
    return _playerView;
}

#pragma mark -
#pragma mark -- set方法 --
- (void)setType:(TTAVPlayerType)type{
    _type = type;
    self.playerView.type = type;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.view addSubview:self.playerView];
    TT_WS(ws);
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view);
    }];
    
    [_playerView setClickPlayerBackBlock:^(TTPlayerOrientation fromOrientation) {
        [ws closePlayer];
    }];
}

- (void)closePlayer{
    [_playerView pause];
    [_playerView close];
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

// 支持转屏
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{    // 返回默认情况
    return UIInterfaceOrientationMaskLandscape;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // 返回默认情况
    return UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
