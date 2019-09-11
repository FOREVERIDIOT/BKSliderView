//
//  UIViewController+BKPageControlView.m
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2019/8/21.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "UIViewController+BKPageControlView.h"
#import <objc/runtime.h>

@implementation UIViewController (BKPageControlView)

-(NSUInteger)bk_index
{
    NSUInteger index = [objc_getAssociatedObject(self, @"bk_pageCotrolView_index") integerValue];
    return index;
}

-(void)setBk_index:(NSUInteger)bk_index
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_index", @(bk_index), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIScrollView *)bk_mainScrollView
{
    UIScrollView * bk_mainScrollView = objc_getAssociatedObject(self, @"bk_pageCotrolView_mainScrollView");
    return bk_mainScrollView;
}

-(void)setBk_mainScrollView:(UIScrollView *)bk_mainScrollView
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_mainScrollView", bk_mainScrollView, OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)bk_MSVScrollEnable
{
    BOOL scrollEnable = [objc_getAssociatedObject(self, @"bk_pageCotrolView_scrollEnable") boolValue];
    return scrollEnable;
}

-(void)setBk_MSVScrollEnable:(BOOL)bk_MSVScrollEnable
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_scrollEnable", @(bk_MSVScrollEnable), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(BKPageControlView *)bk_pageControlView
{
    BKPageControlView * pageControlView = objc_getAssociatedObject(self, @"bk_pageCotrolView");
    return pageControlView;
}

-(void)setBk_pageControlView:(BKPageControlView *)bk_pageControlView
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView", bk_pageControlView, OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)bk_isFollowSuperScrollViewScrollDown
{
    BOOL flag = [objc_getAssociatedObject(self, @"bk_pageCotrolView_isFollowSuperScrollViewScrollDown") integerValue];
    return flag;
}

-(void)setBk_isFollowSuperScrollViewScrollDown:(BOOL)bk_isFollowSuperScrollViewScrollDown
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_isFollowSuperScrollViewScrollDown", @(bk_isFollowSuperScrollViewScrollDown), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
