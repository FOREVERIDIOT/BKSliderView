//
//  BKPageControlView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPageControlScrollView.h"
#import "BKPageControl.h"
#import "BKPageControlCollectionView.h"
@class BKPageControlView;

@protocol BKPageControlViewDelegate <NSObject>

@optional

/// 开始即将离开index
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willLeaveIndex:(NSUInteger)leaveIndex;

/// 正在切换中index
-(void)pageControlView:(nonnull BKPageControlView *)pageControlView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

/// 切换完成index
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex;

#pragma mark - 主视图滑动代理

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didScrollBgScrollView:(nonnull BKPageControlScrollView*)bgScrollView;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willBeginDraggingBgScrollView:(nonnull BKPageControlScrollView*)bgScrollView;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willEndDraggingBgScrollView:(nonnull BKPageControlScrollView*)bgScrollView withVelocity:(CGPoint)velocity targetContentOffset:(nonnull inout CGPoint *)targetContentOffset;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didEndDraggingBgScrollView:(nonnull BKPageControlScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didEndDeceleratingBgScrollView:(nonnull BKPageControlScrollView*)bgScrollView;

#pragma mark - 导航

/// 设置导航目录的UI
-(void)pageControlView:(nonnull BKPageControlView *)pageControlView menu:(nonnull BKPageControlMenu*)menu atIndex:(NSUInteger)index;

@end

@interface BKPageControlView : UIView

#pragma mark - 初始化方法

@property (nonatomic,weak,readonly,nullable) UIViewController * superVC;
/// 子控制器数组 目录是控制器title
@property (nonatomic,copy,nullable) NSArray<UIViewController*> * childControllers;
/// 代理
@property (nonatomic,weak,nullable) id<BKPageControlViewDelegate> delegate;

-(nonnull instancetype)initWithFrame:(CGRect)frame superVC:(nonnull UIViewController*)superVC;
-(nonnull instancetype)initWithFrame:(CGRect)frame superVC:(nonnull UIViewController*)superVC childControllers:(nullable NSArray<UIViewController*>*)childControllers;
-(nonnull instancetype)initWithFrame:(CGRect)frame superVC:(nonnull UIViewController*)superVC childControllers:(nullable NSArray<UIViewController*>*)childControllers delegate:(nullable id<BKPageControlViewDelegate>)delegate;

#pragma mark - BKPageControlView嵌套

/// 上一级BKPageControlView
@property (nonatomic,weak,nullable) BKPageControlView * superLevelPageControlView;

#pragma mark - 索引

/// 选中索引
@property (nonatomic,assign,readonly) NSUInteger displayIndex;

-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(BOOL)animated;
-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(BOOL)animated completion:(nullable void(^)(void))completion;
-(void)setDisplayIndex:(NSUInteger)displayIndex animation:(nullable BOOL(^)(void))animation completion:(nullable void(^)(void))completion;

/// 当前显示的视图
@property (nonatomic,nullable,readonly) UIViewController * displayVC;

/// 获取对应索引的视图 如果没有创建或者超出最大索引则返回nil
/// @param index 索引
-(nullable UIViewController*)getViewControllerAtIndex:(NSUInteger)index;

#pragma mark - 主视图

/// 主视图（竖直滚动）
@property (nonatomic,strong,nonnull) BKPageControlScrollView * bgScrollView;
/// 设置主视图滚动到最顶部
-(void)setBgScrollViewScrollToTop;

#pragma mark - 第二级视图

/// 头视图
@property (nonatomic,strong,nullable) UIView * headerView;
/// 内容视图(包含导航和内容)
@property (nonatomic,strong,nonnull) UIView * contentView;

#pragma mark - 导航视图（第三级）

/// 导航视图
@property (nonatomic,strong,nonnull) BKPageControl * menuView;

#pragma mark - 内容视图（第三级）

/// 详情内容视图
@property (nonatomic,strong,nonnull) BKPageControlCollectionView * collectionView;
/// 详情内容视图左右插入量 默认0
@property (nonatomic,assign) CGFloat contentLrInsets;

@end



