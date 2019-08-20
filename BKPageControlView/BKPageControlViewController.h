//
//  BKPageControlViewController.h
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2019/8/19.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BKPageControlView;
@class BKPageControlBgScrollView;

//修改主滚动视图 userInfo @{@"bk_index" : @(索引), @"bk_mainScrollView" : 主滚动视图UIScrollView}
UIKIT_EXTERN NSString * _Nonnull const kBKPCViewChangeMainScrollViewNotification;
//修改主滚动视图的contentSize userInfo @{@"bk_index" : @(索引), @"bk_mainScrollView" : 主滚动视图UIScrollView}
UIKIT_EXTERN NSString * _Nonnull const kBKPCViewChangeMainScrollViewContentSizeNotification;

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlViewController : UIViewController

#pragma mark - 属性

/**
 分页控制视图
 */
@property (nonatomic,weak,nullable) BKPageControlView * bk_pageControlView;
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
 子控制器主滚动视图是否跟随BKPageControlView主滚动视图一起向下滑动 (默认YES, 且BKPageControlView主滚动视图.scrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView)
 有一种情况 当滑动顺序为内容视图时 父滚动视图的contentOffsetY==0 子控制器主滚动视图contentOffsetY>0 此时向下划有特殊需求时可以使用该属性来禁止跟随
 */
@property (nonatomic,assign) BOOL bk_isFollowSuperScrollViewScrollDown;

#pragma mark - 滑动主视图

/**
 开始滑动主视图
 
 @param bgScrollView 主滚动视图
 */
-(void)bk_willBeginDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

/**
 滑动主视图
 
 @param bgScrollView 主滚动视图
 */
-(void)bk_didScrollSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

/**
 主视图即将停止拖拽
 
 @param bgScrollView 主滚动视图
 @param velocity 速度
 @param targetContentOffset 目标偏移量
 */
-(void)bk_willEndDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView withVelocity:(CGPoint)velocity targetContentOffset:(nonnull inout CGPoint *)targetContentOffset;

/**
 主视图停止拖拽
 
 @param bgScrollView 主滚动视图
 @param decelerate 是否有惯性
 */
-(void)bk_didEndDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

/**
 主视图惯性结束
 
 @param bgScrollView 主滚动视图
 */
-(void)bk_didEndDeceleratingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

@end

NS_ASSUME_NONNULL_END
