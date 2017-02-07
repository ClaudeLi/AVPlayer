//
//  TTAVPlayerView+Layout.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayerView.h"

@interface TTAVPlayerView (Layout)

- (void)_initial;

- (void)_setPortraitLayout;

- (void)_setLandscapeLayout;

- (void)_clearVaules;

- (void)_showBar;

- (void)_showBar:(BOOL)isReset;

- (void)_hideBar;

- (void)removeTimer;

- (void)showTipsWithTime:(CGFloat)time;

@end
