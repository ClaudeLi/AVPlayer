//
//  PlayerViewController.h
//  AVPlayer
//
//  Created by ClaudeLi on 16/4/13.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"

@interface PlayerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet VideoPlayer *videoPlayer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@end
