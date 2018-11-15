//
//  BKSlideView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSlideMenuView.h"
@class BKSlideView;

@protocol BKSlideViewDelegate <NSObject>

@required

/**
 创建对应index的vc
 
 @param slideView BKSlideView
 @param index     索引 从0开始
 */
-(void)slideView:(BKSlideView*)slideView createViewControllerWithIndex:(NSUInteger)index;

@optional

/**
 准备离开index

 @param leaveIndex 离开的index
 */
-(void)slideView:(BKSlideView*)slideView leaveIndex:(NSUInteger)leaveIndex;

/**
 切换index

 @param slideView BKSlideView
 @param switchIndex 切换的index
 @param leaveIndex 离开的index
 */
-(void)slideView:(BKSlideView*)slideView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex;

/**
 修改详情内容视图的frame

 @param slideView BKSlideView
 */
-(void)slideViewDidChangeFrame:(BKSlideView*)slideView;

#pragma mark - 主视图滑动代理

/**
 滑动主视图
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView didScrollBgScrollView:(UIScrollView*)bgScrollView;

/**
 开始滑动主视图
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView willBeginDraggingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图惯性结束
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView didEndDeceleratingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图停止拖拽
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView didEndDraggingBgScrollView:(UIScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

@end

@interface BKSlideView : UIView

/**
 初始化方法

 @param frame 坐标大小
 @param delegate 代理
 @param viewControllers 展示的vc数组 (以vc的title作为创建标志符)
 @return BKSlideView
 */
-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BKSlideViewDelegate>)delegate viewControllers:(NSArray*)viewControllers;

/**
 代理
 */
@property (nonatomic,weak) id<BKSlideViewDelegate> delegate;
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
@property (nonatomic,strong) BKSlideMenuView * menuView;

#pragma mark - 内容视图（第三级）

/**
 详情内容视图
 */
@property (nonatomic,strong) UICollectionView * collectionView;

@end



