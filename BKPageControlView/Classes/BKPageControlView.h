//
//  BKPageControlView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPageControlBgScrollView.h"
#import "BKPageControlMenuView.h"
#import "UIViewController+BKPageControlView.h"
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

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didScrollBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willBeginDraggingBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willEndDraggingBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView withVelocity:(CGPoint)velocity targetContentOffset:(nonnull inout CGPoint *)targetContentOffset;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didEndDraggingBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didEndDeceleratingBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

#pragma mark - 导航

/// 设置导航目录的UI
-(void)pageControlView:(nonnull BKPageControlView *)pageControlView menu:(nonnull BKPageControlMenu*)menu atIndex:(NSUInteger)index;

@end

@interface BKPageControlView : UIView

#pragma mark - 初始化方法

/**
 初始化方法
 
 @param frame 坐标大小
 @param childControllers 展示的子控制器数组 (子控制器的标题就是目录中的标题)
 @param superVC 父视图 (用于保存子控制器)
 @return BKPageControlView
 */
-(nonnull instancetype)initWithFrame:(CGRect)frame childControllers:(nullable NSArray<UIViewController*>*)childControllers superVC:(nonnull UIViewController*)superVC;

/**
 初始化方法

 @param frame 坐标大小
 @param delegate 代理
 @param childControllers 展示的子控制器数组 (子控制器的标题就是目录中的标题)
 @param superVC 父视图 (用于保存子控制器)
 @return BKPageControlView
 */
-(nonnull instancetype)initWithFrame:(CGRect)frame delegate:(nullable id<BKPageControlViewDelegate>)delegate childControllers:(nullable NSArray<UIViewController*>*)childControllers superVC:(nonnull UIViewController*)superVC;

/**
 代理
 */
@property (nonatomic,weak,nullable) id<BKPageControlViewDelegate> delegate;
/**
 展示的子控制器数组 (子控制器的标题就是目录中的标题)
 */
@property (nonatomic,copy,nullable) NSArray<UIViewController*> * childControllers;
/**
 父视图 (用于保存展示的子控制器)
 */
@property (nonatomic,weak,readonly,nullable) UIViewController * superVC;

#pragma mark - BKPageControlView嵌套

/**
 上一级BKPageControlView
 */
@property (nonatomic,weak,nullable) BKPageControlView * superLevelPageControlView;

#pragma mark - 索引

/**
 选中索引 从0开始
 (displayIndex >= [viewControllers count] - 1 时 displayIndex = [viewControllers count] - 1)
 */
@property (nonatomic,assign) NSUInteger displayIndex;

/**
 修改选中索引

 @param displayIndex 选中索引 从0开始
 (displayIndex >= [viewControllers count] - 1 时 displayIndex = [viewControllers count] - 1)
 @param animated 动画中
 @param completion 完成
 */
-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(nullable void (^)(void))animated completion:(nullable void(^)(void))completion;

/**
 当前选中索引显示的控制器
 */
@property (nonatomic,nullable,readonly) UIViewController * displayVC;

#pragma mark - 主视图

/**
 主视图（竖直滚动）
 */
@property (nonatomic,strong,nonnull) BKPageControlBgScrollView * bgScrollView;

#pragma mark - 第二级视图

/**
 头视图
 */
@property (nonatomic,strong,nullable) UIView * headerView;

/**
 内容视图(包含导航和内容)
 */
@property (nonatomic,strong,nonnull) UIView * contentView;

#pragma mark - 导航视图（第三级）

/**
 导航视图
 */
@property (nonatomic,strong,nonnull) BKPageControlMenuView * menuView;

#pragma mark - 内容视图（第三级）

/**
 详情内容视图
 */
@property (nonatomic,strong,nonnull) UICollectionView * collectionView;
/**
 详情内容视图左右插入量 默认0
 */
@property (nonatomic,assign) CGFloat contentLrInsets;

@end



