//
//  BKPageControlView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPageControlBgScrollView.h"
#import "BKPageControlMenuView.h"
@class BKPageControlView;

@protocol BKPageControlViewDelegate <NSObject>

@required

/// 初始化显示的视图
/// @param pageControlView BKPageControlView
/// @param index 索引
-(nonnull UIViewController*)pageControlView:(nonnull BKPageControlView*)pageControlView initializeIndex:(NSUInteger)index;

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

@property (nonatomic,weak,readonly,nullable) UIViewController * superVC;
/// 导航目录
@property (nonatomic,copy,nullable) NSArray<NSString*> * menuTitles;
/// 代理
@property (nonatomic,weak,nullable) id<BKPageControlViewDelegate> delegate;

-(nonnull instancetype)initWithFrame:(CGRect)frame superVC:(nonnull UIViewController*)superVC;
-(nonnull instancetype)initWithFrame:(CGRect)frame superVC:(nonnull UIViewController*)superVC menuTitles:(nullable NSArray<NSString*>*)menuTitles;
-(nonnull instancetype)initWithFrame:(CGRect)frame superVC:(nonnull UIViewController*)superVC menuTitles:(nullable NSArray<NSString*>*)menuTitles delegate:(nullable id<BKPageControlViewDelegate>)delegate;

#pragma mark - BKPageControlView嵌套

/// 上一级BKPageControlView
@property (nonatomic,weak,nullable) BKPageControlView * superLevelPageControlView;

#pragma mark - 索引

/// 选中索引
@property (nonatomic,assign) NSUInteger displayIndex;

/// 修改选中索引
/// @param displayIndex 选中索引
/// @param animated 动画
/// @param completion 完成回调
-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(nullable void (^)(void))animated completion:(nullable void(^)(void))completion;

/// 当前显示的视图
@property (nonatomic,nullable,readonly) UIViewController * displayVC;

/// 获取对应索引的视图 如果没有创建或者超出最大索引则返回nil
/// @param index 索引
-(nullable UIViewController*)getViewControllerAtIndex:(NSUInteger)index;

#pragma mark - 主视图

/// 主视图（竖直滚动）
@property (nonatomic,strong,nonnull) BKPageControlBgScrollView * bgScrollView;
/// 设置主视图滚动到最顶部
-(void)setBgScrollViewScrollToTop;

#pragma mark - 第二级视图

/// 头视图
@property (nonatomic,strong,nullable) UIView * headerView;
/// 内容视图(包含导航和内容)
@property (nonatomic,strong,nonnull) UIView * contentView;

#pragma mark - 导航视图（第三级）

/// 导航视图
@property (nonatomic,strong,nonnull) BKPageControlMenuView * menuView;

#pragma mark - 内容视图（第三级）

/// 详情内容视图
@property (nonatomic,strong,nonnull) UICollectionView * collectionView;
/// 详情内容视图左右插入量 默认0
@property (nonatomic,assign) CGFloat contentLrInsets;

@end



