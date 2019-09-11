//
//  UIViewController+BKPageControlView.h
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2019/8/21.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BKPageControlView;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (BKPageControlView)

/**
 所在索引
 */
@property (nonatomic,assign) NSUInteger bk_index;
/**
 子控制器的主滚动视图(用于计算出BKPageControlView主视图的contentSize)
 此属性会自动获取，也可以自己赋值更改。
 */
@property (nonatomic,weak,nullable) UIScrollView * bk_mainScrollView;
/**
 该索引下子控制器的主滚动视图是否能滑动(默认不允许滑动, 该属性在有头视图、有多层BKPageControlView时有效)
 */
@property (nonatomic,assign) BOOL bk_MSVScrollEnable;
/**
 分页控制视图
 */
@property (nonatomic,weak,nullable) BKPageControlView * bk_pageControlView;
/**
 子控制器主滚动视图是否跟随BKPageControlView主滚动视图一起向下滑动 (默认YES, 且BKPageControlView主滚动视图.scrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView)
 有一种情况 当滑动顺序为内容视图时 父滚动视图的contentOffsetY==0 子控制器主滚动视图contentOffsetY>0 此时向下划有特殊需求时可以使用该属性来禁止跟随
 */
@property (nonatomic,assign) BOOL bk_isFollowSuperScrollViewScrollDown;

@end

NS_ASSUME_NONNULL_END
