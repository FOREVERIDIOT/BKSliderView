//
//  UIViewController+BKPageControlView.h
//  DSCnliveShopSDK
//
//  Created by BIKE on 2019/8/21.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BKPageControlView;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (BKPageControlView)

/// 所在索引
@property (nonatomic,assign) NSUInteger bk_pcv_index;
/// 子控制器的主滚动视图(用于计算出BKPageControlView主视图的contentSize) 此属性会自动获取，也可以自己赋值更改。
@property (nonatomic,weak,nullable) UIScrollView * bk_pcv_mainScrollView;
/// 分页控制视图
@property (nonatomic,weak,nullable) BKPageControlView * bk_pcv_pageControlView;

@end

NS_ASSUME_NONNULL_END
