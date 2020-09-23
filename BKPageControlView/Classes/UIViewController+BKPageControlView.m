//
//  UIViewController+BKPageControlView.m
//  DSCnliveShopSDK
//
//  Created by BIKE on 2019/8/21.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "UIViewController+BKPageControlView.h"
#import <objc/runtime.h>

@implementation UIViewController (BKPageControlView)

-(NSUInteger)bk_pcv_index
{
    NSUInteger index = [objc_getAssociatedObject(self, @"bk_pageCotrolView_index") integerValue];
    return index;
}

-(void)setBk_pcv_index:(NSUInteger)bk_pcv_index
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_index", @(bk_pcv_index), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIScrollView *)bk_pcv_mainScrollView
{
    UIScrollView * scrollView = objc_getAssociatedObject(self, @"bk_pageCotrolView_mainScrollView");
    return scrollView;
}

-(void)setBk_pcv_mainScrollView:(UIScrollView *)bk_pcv_mainScrollView
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_mainScrollView", bk_pcv_mainScrollView, OBJC_ASSOCIATION_ASSIGN);
}

-(BKPageControlView *)bk_pcv_pageControlView
{
    BKPageControlView * pageControlView = objc_getAssociatedObject(self, @"bk_pageCotrolView_pageCotrolView");
    return pageControlView;
}

-(void)setBk_pcv_pageControlView:(BKPageControlView *)bk_pcv_pageControlView
{
    objc_setAssociatedObject(self, @"bk_pageCotrolView_pageCotrolView", bk_pcv_pageControlView, OBJC_ASSOCIATION_ASSIGN);
}

@end
