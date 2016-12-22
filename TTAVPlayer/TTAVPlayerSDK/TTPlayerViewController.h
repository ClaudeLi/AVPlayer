//
//  TTPlayerViewController.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAVPlayerView.h"

@interface TTPlayerViewController : UIViewController

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSArray  *itemArray;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL isFullScreen;

- (void)pause;

- (void)close;

@end
