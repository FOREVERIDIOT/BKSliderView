//
//  NSString+BKSlideView.m
//  BKSliderView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "NSString+BKSlideView.h"

@implementation NSString (BKSlideView)

#pragma mark - 文本计算

-(CGSize)calculateSizeWithUIHeight:(CGFloat)height font:(UIFont*)font
{
    if (!self || height <= 0 || !font) {
        return CGSizeZero;
    }
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                     options: NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    
    return rect.size;
}

@end
