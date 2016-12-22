//
//  TTAVPlayerSDK.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/21.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#ifndef TTAVPlayerSDK_h
#define TTAVPlayerSDK_h

#import <Masonry.h>
#import "TTPlayerViewController.h"
#import "UIView+UIViewController.h"

#ifdef DEBUG
#define TTLog(format, ...) printf("\n[%s] %s [in line %d] => %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define TTLog(format, ...)
#endif

#define TT_WS(weakSelf)    __weak __typeof(&*self)weakSelf = self;

#define TTColor_MinimumColor    [UIColor greenColor]

#define TTColor_TitleColor      [UIColor yellowColor]

#endif /* TTAVPlayerSDK_h */
