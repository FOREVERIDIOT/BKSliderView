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
    
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //利用path进行绘制三角形
    
    CGContextBeginPath(context);//标记
    
    CGContextMoveToPoint(context, 0, 0);//设置起点
    
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height/2.0f);
    
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [[UIColor blackColor] setFill]; //设置填充色
    
    [[UIColor grayColor] setStroke]; //设置边框颜色
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}


@end
