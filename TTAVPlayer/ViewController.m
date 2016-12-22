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

@end

@implementation ViewController

- (TTPlayerViewController *)player{
    if (!_player) {
        _player = [[TTPlayerViewController alloc] init];
        _player.parentView = self.view;
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取测试数据Url数组
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestVideo" ofType:@"txt"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:path];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *array = [string componentsSeparatedByString:@"\n"];
    
    // 设置Player
    self.player.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width/16.0 * 9.0);
    // 正在项目使用中 涉及到分享什么的 需要传入的可能是model数组, demo只做参考 请自行修改
    self.player.itemArray = array;
    self.player.index = 0;
    
//    // 单独视频直接传视频Url/单个model
//    [self.player setUrlString:@"http://v.tiaooo.com/lo_M1PD6r1v1DG4k632svu3bQdWH"];
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
