//
//  BKPageControl.h
//  BKPageControlView
//
//  Created by BIKE on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPageControlMenu.h"
#import "BKPageControlMenuPropertyModel.h"
@class BKPageControl;
@class BKPageControlView;

typedef NS_OPTIONS(NSUInteger, BKPageControlMenuSelectStyle) {
    BKPageControlMenuSelectStyleNone = 0,                    //无效果
    BKPageControlMenuSelectStyleDisplayLine = 1 << 0,        //显示底部选中的线
    BKPageControlMenuSelectStyleChangeColor = 1 << 1,        //选中的字体颜色会有变化
    BKPageControlMenuSelectStyleChangeFont = 1 << 2,          //选中的字体大小会有变化
    BKPageControlMenuSelectStyleDisplayBgView = 1 << 3,          //显示文字背景框
};

typedef NS_ENUM(NSUInteger, BKPageControlMenuTitleFontWeight) {
    BKPageControlMenuTitleFontWeightLight,                     //细体
    BKPageControlMenuTitleFontWeightRegular,                   //正常体
    BKPageControlMenuTitleFontWeightMedium,                    //粗体
};

typedef NS_ENUM(NSUInteger, BKPageControlMenuSelectLineStyle) {
    BKPageControlMenuSelectLineStyleFollowMenuTitleWidth,      //随title的宽变化
    BKPageControlMenuSelectLineStyleConstantWidth              //恒定宽
};

@protocol BKPageControlDelegate <NSObject>

@optional

/// 改变menuView的frame
-(void)changeMenuViewFrame;

/// 开始即将离开index
-(void)menuView:(nonnull BKPageControl*)menuView willLeaveIndex:(NSUInteger)leaveIndex;

/// 正在切换中index
-(void)menuView:(nonnull BKPageControl*)menuView switchingSelectIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

/// 切换完成index
-(void)menuView:(nonnull BKPageControl*)menuView switchIndex:(NSUInteger)switchIndex;

/// 设置menu上的UI
-(void)menu:(nonnull BKPageControlMenu*)menu atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControl : UIView

#pragma mark - UI

/// 主滚动视图
@property (nonatomic,weak) BKPageControlView * pageControlView;
/// 导航内容视图
@property (nonatomic,strong) UIScrollView * contentView;
/// 导航内容视图底部分割线
@property (nonatomic,strong) UIImageView * bottomLine;

#pragma mark - 属性

/// 代理
@property (nonatomic,weak) id<BKPageControlDelegate> delegate;
/// 导航标题数组
@property (nonatomic,copy) NSArray * titles;
/// 导航内容视图左右插入间距 默认0
@property (nonatomic,assign) CGFloat lrInset;
/// 导航内容视图的宽 默认0（实际和导航视图一样宽）
@property (nonatomic,assign) CGFloat contentViewWidth;

/// 当前选中索引
@property (nonatomic,assign) NSUInteger selectIndex;
/// 修改选中索引
/// @param selectIndex 选中索引
/// @param animated 动画
/// @param completion 完成回调
-(void)setSelectIndex:(NSUInteger)selectIndex animated:(void (^)(void))animated completion:(void (^)(void))completion;

#pragma mark - 菜单设置

/// 等分宽度,为0时随标题长度而改变 默认0
@property (nonatomic,assign) CGFloat menuEqualDivisionW;
/// 选中的格式 默认为 BKPageControlMenuSelectStyleDisplayLine | BKPageControlMenuSelectStyleChangeColor
@property (nonatomic,assign) BKPageControlMenuSelectStyle menuSelectStyle;
/// 间距 默认20  当menuEqualDivisionW==0时有效
@property (nonatomic,assign) CGFloat menuSpace;
/// 标题行数 默认1行
@property (nonatomic,assign) CGFloat menuNumberOfLines;
/// 标题行间距 默认0
@property (nonatomic,assign) CGFloat menuLineSpacing;
/// 标题内容插入量 默认UIEdgeInsetsZero
@property (nonatomic,assign) UIEdgeInsets menuContentInset;
/// 未选中的字号 默认14
@property (nonatomic,assign) CGFloat menuNormalTitleFontSize;
/// 选中的字号 默认17
@property (nonatomic,assign) CGFloat menuSelectTitleFontSize;
/// 字体粗细 默认正常体
@property (nonatomic,assign) BKPageControlMenuTitleFontWeight menuTitleFontWeight;
/// 未选中的颜色 默认[UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6] 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
@property (nonatomic,strong,nullable) UIColor * menuNormalTitleColor;
/// 选中的颜色 默认[UIColor colorWithRed:0 green:0 blue:0 alpha:1] 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
@property (nonatomic,strong,nullable) UIColor * menuSelectTitleColor;
/// 未选中的文字背景颜色 默认nil 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
@property (nonatomic,strong,nullable) UIColor * menuNormalTitleBgColor;
/// 未选中的文字背景颜色 默认nil 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
@property (nonatomic,strong,nullable) UIColor * menuSelectTitleBgColor;
/// 标题背景上下左右插入量 默认UIEdgeInsetsZero和menuView一样大小
@property (nonatomic,assign) UIEdgeInsets menuTitleBgContentInset;
/// 标题背景角度 默认0
@property (nonatomic,assign) CGFloat menuTitleBgAngle;

#pragma mark - 选中导航的线设置

/// 菜单标题底部的线选中样式 默认BKPageControlMenuSelectLineStyleFollowMenuTitleWidth
@property (nonatomic,assign) BKPageControlMenuSelectLineStyle selectLineStyle;
/// 菜单标题底部的线恒定宽 默认15 当selectLineStyle == BKPageControlMenuSelectLineStyleConstantWidth有效
@property (nonatomic,assign) CGFloat selectLineConstantW;
/// 菜单标题底部线的高度 默认2
@property (nonatomic,assign) CGFloat selectLineHeight;
/// 菜单标题底部线距离底部的距离
@property (nonatomic,assign) CGFloat selectLineBottomMargin;
/// 菜单标题底部线的颜色 默认[UIColor blackColor] 设置后selectLineBgGradientColor设置为nil
@property (nonatomic,strong,nullable) UIColor * selectLineBgColor;
/// 菜单标题底部线的渐变颜色 从左到右 默认nil 设置后selectLineBgColor设置为nil
@property (nonatomic,strong,nullable) NSArray<UIColor*> * selectLineBgGradientColor;

#pragma mark - 内容视图滑动的方法

/// 滚动collectionView
-(void)collectionViewDidScroll:(UICollectionView*)collectionView;
/// 结束滚动collectionView
-(void)collectionViewDidEndDecelerating:(UICollectionView*)collectionView;

#pragma mark - 公开方法

/// 获取可见的menu
-(NSArray<BKPageControlMenu*> *)getVisibleMenu;

/// 获取全部的menu属性
-(NSArray<BKPageControlMenuPropertyModel*> *)getTotalMenuProperty;

@end

NS_ASSUME_NONNULL_END
