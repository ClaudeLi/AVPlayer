//
//  TTAVPlayerGestureView.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/16.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTAVPlayerGestureView : UIView

/**
 *  单击时/双击时,判断tap的numberOfTapsRequired
 */
@property (nonatomic, copy)void (^userTapGestureBlock)(NSUInteger number);
/**
 * 开始触摸
 */
@property (nonatomic, copy)CGFloat (^touchesBeganWithPointBlock)();

/**
 * 左右移动
 */
@property (nonatomic, copy)void (^toucheMoveWithPointBlock)(CGFloat value, BOOL isFast);

/**
 * 结束触摸
 */
@property (nonatomic, copy)void (^touchesEndWithPointBlock)(CGFloat value);


@end
