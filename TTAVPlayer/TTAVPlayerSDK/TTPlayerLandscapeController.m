//
//  TTPlayerLandscapeController.m
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTPlayerLandscapeController.h"

@interface TTPlayerLandscapeController ()

@end

@implementation TTPlayerLandscapeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
{    // 返回默认情况
    if (self.orientation == TTPlayerOrientationHomeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationLandscapeRight;
}

@end
