//
//  CustomSelectView.m
//  BKSliderView
//
//  Created by jollyColcors on 16/2/19.
//  Copyright © 2016年 BK. All rights reserved.
//

#import "CustomSelectView.h"

@implementation CustomSelectView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 0, self.frame.size.height);
    
    CGContextAddLineToPoint(context, self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    
    CGContextClosePath(context);
    
    [[UIColor blackColor] setFill];
    
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
