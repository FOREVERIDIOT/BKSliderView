//
//  NSString+BKSlideView.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (BKSlideView)

#pragma mark - 文本计算

/**
 计算文本大小(固定高)
 
 @param height 固定高度
 @param font 字体大小
 @return 文本大小
 */
-(CGSize)calculateSizeWithUIHeight:(CGFloat)height font:(UIFont*)font;

@end

NS_ASSUME_NONNULL_END
