//
//  TTVideoItem.h
//  Tiaooo
//
//  Created by ClaudeLi on 2016/12/23.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTVideoItem : NSObject

@property (nonatomic, assign) BOOL isNetwork;
@property (nonatomic, copy) NSString *playUrl;      // 播放地址
@property (nonatomic, copy) NSString *url;          // 网络地址

@property (nonatomic, copy) NSString *vid;          // 视频id
@property (nonatomic, copy) NSString *title;        // 视频title
@property (nonatomic, copy) NSString *cover;        // 封面

@end
