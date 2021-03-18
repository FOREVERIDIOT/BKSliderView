//
//  BKPageControlScrollView.m
//  BKPageControlView
//
//  Created by BIKE on 2019/7/10.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPageControlScrollView.h"

@interface BKPageControlScrollView()

@end

@implementation BKPageControlScrollView

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceHorizontal = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark - 控制不能横向偏移

-(void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:CGPointMake(0, contentOffset.y)];
}

@end
