//
//  BKPageControlSelectLine.m
//  TestHomePage
//
//  Created by BIKE on 2020/8/25.
//  Copyright © 2020 BIKE. All rights reserved.
//

#import "BKPageControlSelectLine.h"

@interface BKPageControlSelectLine()

@property (nonatomic,strong) CAGradientLayer * gradientLayer;

@end

@implementation BKPageControlSelectLine

//不能使用backgroundColor方法 在xcode看图层时会走此方法导致渐变色删除
//-(UIColor *)backgroundColor
//{
//    _colors = nil;
//    [_gradientLayer removeFromSuperlayer];
//    _gradientLayer = nil;
//
//    return [super backgroundColor];
//}

-(void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    
    _colors = nil;
    [_gradientLayer removeFromSuperlayer];
    _gradientLayer = nil;
    
    self.backgroundColor = _bgColor;
}

-(void)setColors:(NSArray<UIColor *> *)colors
{
    _colors = colors;
    
    _bgColor = nil;
    
    __block NSMutableArray * gLayerColors = [NSMutableArray array];
    [_colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [gLayerColors addObject:(__bridge id)obj.CGColor];
    }];
    self.gradientLayer.colors = [gLayerColors copy];
}

#pragma mark - layoutSubviews

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - CAGradientLayer

-(CAGradientLayer*)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [[CAGradientLayer alloc] init];
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
        _gradientLayer.opacity = 1;
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

@end
