//
//  BKSliderView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSliderMenuView.h"
@class BKSliderView;

@protocol BKSliderViewDelegate <NSObject>

@optional

/**
 第一次显示对应index的vc
 
 @param sliderView BKSliderView
 @param viewController 控制器
 @param index 索引
 */
-(void)sliderView:(BKSliderView*)sliderView firstDisplayViewController:(UIViewController*)viewController index:(NSUInteger)index;

/**
 准备离开index

 @param leaveIndex 离开的index
 */
-(void)sliderView:(BKSliderView*)sliderView willLeaveIndex:(NSUInteger)leaveIndex;

/**
 切换index中

 @param sliderView BKSliderView
 @param switchingIndex 切换中的index
 @param leavingIndex 离开中的index
 @param percentage 百分比
 */
-(void)sliderView:(BKSliderView *)sliderView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

/**
 切换index

 @param sliderView BKSliderView
 @param switchIndex 切换的index
 @param leaveIndex 离开的index
 */
-(void)sliderView:(BKSliderView*)sliderView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex;

#pragma mark - 主视图滑动代理

/**
 滑动主视图
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView didScrollBgScrollView:(UIScrollView*)bgScrollView;

/**
 开始滑动主视图
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView willBeginDraggingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图惯性结束
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView didEndDeceleratingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图停止拖拽
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView didEndDraggingBgScrollView:(UIScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

#pragma mark - 导航

/**
 导航视图刷新UI代理

 @param sliderView BKSliderView
 @param menuView 导航视图
 */
-(void)sliderView:(BKSliderView *)sliderView refreshMenuUI:(BKSliderMenuView*)menuView;

@end

@interface BKSliderView : UIView

/**
 初始化方法

 @param frame 坐标大小
 @param delegate 代理
 @param viewControllers 展示的vc数组 (以vc的title作为创建标志符)
 @return BKSliderView
 */
-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BKSliderViewDelegate>)delegate viewControllers:(NSArray*)viewControllers;

/**
 代理
 */
@property (nonatomic,weak) id<BKSliderViewDelegate> delegate;
/**
 展示的vc数组 (以vc的title作为创建标志符)
 */
@property (nonatomic,copy) NSArray<UIViewController*> * viewControllers;
/**
 选中索引 从0开始
 (selectIndex >= [viewControllers count] - 1 时 selectIndex = [viewControllers count] - 1)
 */
@property (nonatomic,assign) NSUInteger selectIndex;

#pragma mark - 主视图

/**
 主视图（竖直滚动）
 */
@property (nonatomic,strong) UIScrollView * bgScrollView;

#pragma mark - 第二级视图

/**
 头视图
 */
@property (nonatomic,strong) UIView * headerView;

/**
 内容视图(包含导航和内容)
 */
@property (nonatomic,strong) UIView * contentView;

#pragma mark - 导航视图（第三级）

/**
 导航视图
 */
@property (nonatomic,strong) BKSliderMenuView * menuView;

#pragma mark - 内容视图（第三级）

/**
 详情内容视图
 */
@property (nonatomic,strong) UICollectionView * collectionView;

/**
 用自定义的滑动手势代替系统的滑动手势(因项目需求需要嵌套两层sliderView，并且两层都需要使用左右滑动，所以这个属性诞生了)
 */
@property (nonatomic,assign) BOOL useCsPanGestureOnCollectionView;

/**
 自定义滑动手势
 */
@property (nonatomic,strong,readonly) UIPanGestureRecognizer * csCollectionViewPanGesture;

@end



