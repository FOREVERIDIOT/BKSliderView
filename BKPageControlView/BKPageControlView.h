//
//  BKPageControlView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPageControlViewController.h"
#import "BKPageControlMenuView.h"
@class BKPageControlView;

@protocol BKPageControlViewDelegate <NSObject>

@optional

/**
 准备离开index

 @param leaveIndex 离开的index
 */
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willLeaveIndex:(NSUInteger)leaveIndex;

/**
 切换index中

 @param pageControlView BKPageControlView
 @param switchingIndex 切换中的index
 @param leavingIndex 离开中的index
 @param percentage 百分比
 */
-(void)pageControlView:(nonnull BKPageControlView *)pageControlView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

/**
 切换index

 @param pageControlView BKPageControlView
 @param switchIndex 切换的index
 @param leaveIndex 离开的index
 */
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex;

#pragma mark - 主视图滑动代理

/**
 滑动主视图
 
 @param pageControlView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didScrollBgScrollView:(nonnull UIScrollView*)bgScrollView;

/**
 开始滑动主视图
 
 @param pageControlView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView willBeginDraggingBgScrollView:(nonnull UIScrollView*)bgScrollView;

/**
 主视图惯性结束
 
 @param pageControlView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didEndDeceleratingBgScrollView:(nonnull UIScrollView*)bgScrollView;

/**
 主视图停止拖拽
 
 @param pageControlView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)pageControlView:(nonnull BKPageControlView*)pageControlView didEndDraggingBgScrollView:(nonnull UIScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

#pragma mark - 导航

/**
 设置导航视图中menu上的icon和选中的icon
 
 @param menu menu
 @param iconImageView icon
 @param selectIconImageView 选中的icon
 @param index 索引
 */
-(void)pageControlView:(nonnull BKPageControlView *)pageControlView menu:(nonnull BKPageControlMenu*)menu settingIconImageView:(nonnull UIImageView*)iconImageView selectIconImageView:(nonnull UIImageView*)selectIconImageView atIndex:(NSUInteger)index;

@end

@interface BKPageControlView : UIView

#pragma mark - 初始化方法

/**
 初始化方法

 @param frame 坐标大小
 @param delegate 代理
 @param childControllers 展示的子控制器数组 必须遵循代理BKPageControlViewController (子控制器的标题就是目录中的标题)
 @param superVC 父视图 (用于保存子控制器)
 @return BKPageControlView
 */
-(nonnull instancetype)initWithFrame:(CGRect)frame delegate:(nullable id<BKPageControlViewDelegate>)delegate childControllers:(nullable NSArray<UIViewController<BKPageControlViewController>*>*)childControllers superVC:(nonnull UIViewController*)superVC;

/**
 代理
 */
@property (nonatomic,weak,nullable) id<BKPageControlViewDelegate> delegate;
/**
 展示的子控制器数组 必须遵循代理BKPageControlViewController (子控制器的标题就是目录中的标题)
 */
@property (nonatomic,copy,nullable) NSArray<UIViewController<BKPageControlViewController>*> * childControllers;
/**
 父视图 (用于保存展示的子控制器)
 */
@property (nonatomic,weak,readonly,nullable) UIViewController * superVC;

/**
 选中索引 从0开始
 (selectIndex >= [viewControllers count] - 1 时 selectIndex = [viewControllers count] - 1)
 */
@property (nonatomic,assign) NSUInteger selectIndex;

#pragma mark - 主视图

/**
 主视图（竖直滚动）
 */
@property (nonatomic,strong,nonnull) UIScrollView * bgScrollView;

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

/**
 用自定义的滑动手势代替系统的滑动手势(因项目需求需要嵌套两层pageControlView，并且两层都需要使用左右滑动，所以这个属性诞生了)
 */
@property (nonatomic,assign) BOOL useCsPanGestureOnCollectionView;

/**
 自定义滑动手势
 */
@property (nonatomic,strong,readonly,nullable) UIPanGestureRecognizer * csCollectionViewPanGesture;

@end



