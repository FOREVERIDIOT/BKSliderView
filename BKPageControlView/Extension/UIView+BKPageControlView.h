//
//  UIView+BKPageControlView.h
//  BKPageControlView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (BKPageControlView)

/**
 x
 */
@property (nonatomic,assign) CGFloat bk_x;
/**
 y
 */
@property (nonatomic,assign) CGFloat bk_y;
/**
 width
 */
@property (nonatomic,assign) CGFloat bk_width;
/**
 height
 */
@property (nonatomic,assign) CGFloat bk_height;
/**
 centerX
 */
@property (nonatomic,assign) CGFloat bk_centerX;
/**
 centerY
 */
@property (nonatomic,assign) CGFloat bk_centerY;

@end

NS_ASSUME_NONNULL_END
