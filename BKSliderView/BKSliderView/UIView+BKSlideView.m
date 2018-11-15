//
//  UIView+BKSlideView.m
//  BKSliderView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "UIView+BKSlideView.h"

@implementation UIView (BKSlideView)

#pragma mark - 附加属性

-(void)setBk_x:(CGFloat)bk_x
{
    if (bk_x == NAN) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = bk_x;
    self.frame = frame;
}

-(CGFloat)bk_x
{
    return self.frame.origin.x;
}

-(void)setBk_y:(CGFloat)bk_y
{
    if (bk_y == NAN) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.origin.y = bk_y;
    self.frame = frame;
}

-(CGFloat)bk_y
{
    return self.frame.origin.y;
}

-(void)setBk_width:(CGFloat)bk_width
{
    if (bk_width == NAN) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.size.width = bk_width;
    self.frame = frame;
}

-(CGFloat)bk_width
{
    return self.frame.size.width;
}

-(void)setBk_height:(CGFloat)bk_height
{
    if (bk_height == NAN) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.size.height = bk_height;
    self.frame = frame;
}

-(CGFloat)bk_height
{
    return self.frame.size.height;
}

-(void)setBk_centerX:(CGFloat)bk_centerX
{
    if (bk_centerX == NAN) {
        return;
    }
    
    CGPoint center = self.center;
    center.x = bk_centerX;
    self.center = center;
}

-(CGFloat)bk_centerX
{
    return self.center.x;
}

-(void)setBk_centerY:(CGFloat)bk_centerY
{
    if (bk_centerY == NAN) {
        return;
    }
    
    CGPoint center = self.center;
    center.y = bk_centerY;
    self.center = center;
}

-(CGFloat)bk_centerY
{
    return self.center.y;
}

@end
