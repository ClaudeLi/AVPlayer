//
//  MyViewController.m
//  TTAVPlayer
//
//  Created by ClaudeLi on 2017/2/7.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "MyViewController.h"
#import "TTAVPlayerSDK.h"

@interface MyViewController ()

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)gotoLandscapePlayer:(id)sender {
    TTLandscapePlayerController *player = [[TTLandscapePlayerController alloc] initWithType:TTAVPlayerTypeLandscapePlayer];
    player.itemArray = [self getVideoItemArray];
    player.index = 0;
    [self presentViewController:player animated:YES completion:nil];
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
