//
//  NSString+BKSliderView.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (BKSliderView)

#pragma mark - 文本计算

/**
 计算文本大小(固定宽)
 
 @param width 固定宽度
 @param font 字体大小
 @return 文本大小
 */
-(CGSize)calculateSizeWithUIWidth:(CGFloat)width font:(UIFont*)font;

/**
 计算文本大小(固定高)
 
 @param height 固定高度
 @param font 字体大小
 @return 文本大小
 */
-(CGSize)calculateSizeWithUIHeight:(CGFloat)height font:(UIFont*)font;

@end

NS_ASSUME_NONNULL_END
