//
//  ViewController.m
//  TTAVPlayer
//
//  Created by ClaudeLi on 2016/12/20.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "ViewController.h"
#import "TTAVPlayerSDK.h"

@interface ViewController ()

@property (nonatomic) TTPlayerViewController *player;

@property (nonatomic, strong) NSMutableArray *itemArray;

@end

@implementation ViewController

- (NSMutableArray *)itemArray{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (TTPlayerViewController *)player{
    if (!_player) {
        _player = [[TTPlayerViewController alloc] initWithType:TTAVPlayerTypeDefault];
        _player.parentView = self.view;
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置Player
    self.player.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width/16.0 * 9.0);
    // 设置播放视频model数组,
    self.player.itemArray = [self getVideoItemArray];
    self.player.index = 0;
    
//    // 单独视频直接传入单独model
    //[self.player setItem:<#(TTVideoItem *)#>];
}


// 获取测试数据数组
- (NSArray *)getVideoItemArray{
    // 获取测试数据Url数组
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestVideo" ofType:@"txt"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:path];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *urlArray = [string componentsSeparatedByString:@"\n"];
    
    int i = 0;
    NSMutableArray *itemArray = [NSMutableArray array];
    for (NSString *urlStr in urlArray) {
        TTVideoItem *item = [[TTVideoItem alloc] init];
        item.url = urlStr;
        item.vid = TT_intToString(i);
        item.title = TT_intToString(i);
        [itemArray addObject:item];
        i++;
    }
    return [itemArray copy];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!self.player.isFullScreen) {
        [self.player pause];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait ;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
