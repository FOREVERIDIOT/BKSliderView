//
//  BKPageControlBgScrollView.m
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/10.
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

#pragma mark - SDK内部使用的内容添加插入量

-(UIEdgeInsets)interiorContentInsets
{
    return UIEdgeInsetsMake(self.contentInset.top - _interiorAddContentInsets.top,
                            self.contentInset.left - _interiorAddContentInsets.left,
                            self.contentInset.bottom - _interiorAddContentInsets.bottom,
                            self.contentInset.right - _interiorAddContentInsets.right);
}

#pragma mark - SDK内部添加内容插入量

-(void)setInteriorAddContentInsets:(UIEdgeInsets)interiorAddContentInsets
{
    UIEdgeInsets interiorContentInsets = self.interiorContentInsets;
    _interiorAddContentInsets = interiorAddContentInsets;
    self.contentInset = UIEdgeInsetsMake(interiorContentInsets.top + _interiorAddContentInsets.top,
                                         interiorContentInsets.left + _interiorAddContentInsets.left,
                                         interiorContentInsets.bottom + _interiorAddContentInsets.bottom,
                                         interiorContentInsets.right + _interiorAddContentInsets.right);
}

@end
