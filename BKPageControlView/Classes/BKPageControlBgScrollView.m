//
//  BKPageControlBgScrollView.m
//  BKPageControlView
//
//  Created by BIKE on 2019/7/10.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPageControlBgScrollView.h"

@interface BKPageControlBgScrollView()

@end

@implementation BKPageControlBgScrollView

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
    //保证外层嵌套横向滑动scrollView时可以联动，但是有个bug 这个属性设置完后，竖向滑动时偏移量x也会变化，所以重写[super setContentOffset:CGPointMake(0, contentOffset.y)];
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
