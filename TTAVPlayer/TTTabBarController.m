//
//  TTTabBarController.m
//  TTAVPlayer
//
//  Created by ClaudeLi on 2016/12/22.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTTabBarController.h"

@interface TTTabBarController ()

@end

@implementation TTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
