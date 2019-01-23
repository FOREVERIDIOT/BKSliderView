//
//  BKSliderMenuView.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSliderMenu.h"
#import "BKSliderMenuPropertyModel.h"
@class BKSliderMenuView;

typedef NS_OPTIONS(NSUInteger, BKSliderMenuSelectStyle) {
    BKSliderMenuSelectStyleNone = 0,                    //无效果
    BKSliderMenuSelectStyleDisplayLine = 1 << 0,        //显示底部选中的线
    BKSliderMenuSelectStyleChangeColor = 1 << 1,        //选中的字体颜色会有变化
    BKSliderMenuSelectStyleChangeFont = 1 << 2          //选中的字体大小会有变化
};

typedef NS_ENUM(NSUInteger, BKSliderMenuTypesetting) {
    BKSliderMenuTypesettingEqualSpace = 0,              //间距相等
    BKSliderMenuTypesettingEqualWidth                   //menu等宽
};

typedef NS_ENUM(NSUInteger, BKSliderMenuTitleFontWeight) {
    BKSliderMenuTitleFontWeightLight,                     //细体
    BKSliderMenuTitleFontWeightRegular,                   //正常体
    BKSliderMenuTitleFontWeightMedium,                    //粗体
};

typedef NS_ENUM(NSUInteger, BKSliderMenuSelectViewStyle) {
    BKSliderMenuSelectViewStyleFollowMenuTitleWidth,      //随title的宽变化
    BKSliderMenuSelectViewStyleConstantWidth              //恒定宽
};

@protocol BKSliderMenuViewDelegate <NSObject>

@optional

/**
 改变menuView的frame
 */
-(void)changeMenuViewFrame;

/**
 切换index中

 @param switchingIndex 切换中的index
 @param leavingIndex 离开中的index
 @param percentage 百分比
 */
-(void)switchingSelectIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

/**
 点击menu切换index

 @param selectIndex 切换的index
 */
-(void)tapMenuSwitchSelectIndex:(NSUInteger)selectIndex;

/**
 刷新menuUI

 @param menuView BKSliderMenuView
 */
-(void)refreshMenuUI:(BKSliderMenuView*)menuView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BKSliderMenuView : UIView

/**
 代理
 */
@property (nonatomic,weak) id<BKSliderMenuViewDelegate> delegate;
/**
 导航标题数组
 */
@property (nonatomic,copy) NSArray * titles;
/**
 当前选中索引 从0开始
 (selectIndex >= [titles count] - 1 时 selectIndex = [titles count] - 1)
 */
@property (nonatomic,assign) NSUInteger selectIndex;
/**
 是否是点击menu切换index(进行时)
 */
@property (nonatomic,assign,readonly) BOOL isTapMenuSwitchingIndex;

#pragma mark - 导航视图

/**
 导航内容视图
 */
@property (nonatomic,strong) UIScrollView * contentView;
/**
 导航内容视图底部分割线
 */
@property (nonatomic,strong) UIImageView * bottomLine;
/**
 导航内容视图左右插入间距 默认0
 */
@property (nonatomic,assign) CGFloat lrInset;

#pragma mark - 选中导航的线设置

/**
 菜单标题底部的线选中样式 默认BKSliderMenuSelectViewStyleFollowMenuTitleWidth
 */
@property (nonatomic,assign) BKSliderMenuSelectViewStyle selectViewStyle;
/**
 菜单标题底部的线恒定宽 默认15
 当menuSelectViewStyle == BKSliderMenuSelectViewStyleConstantWidth有效
 */
@property (nonatomic,assign) CGFloat selectViewConstantW;
/**
 菜单标题底部线的高度 默认2
 */
@property (nonatomic,assign) CGFloat selectViewHeight;
/**
 菜单标题底部线距离底部的距离
 */
@property (nonatomic,assign) CGFloat selectViewBottomMargin;
/**
 菜单标题底部线的颜色
 */
@property (nonatomic,strong) UIColor * selectViewBackgroundColor;

#pragma mark - 菜单设置

/**
 menu排版 默认BKSliderMenuTypesettingEqualSpace
 选BKSliderMenuTypesettingEqualSpace时参数menuSpace有效
 选BKSliderMenuTypesettingEqualWidth时 例menu有3个时menu的宽为BKSliderMenuView.width/3 间距为0
 */
@property (nonatomic,assign) BKSliderMenuTypesetting menuTypesetting;
/**
 选中的格式
 默认为 BKSliderMenuSelectStyleDisplayLine | BKSliderMenuSelectStyleChangeColor
 */
@property (nonatomic,assign) BKSliderMenuSelectStyle menuSelectStyle;
/**
 间距 默认20
 */
@property (nonatomic,assign) CGFloat menuSpace;
/**
 标题行数 默认1行
 */
@property (nonatomic,assign) CGFloat menuNumberOfLines;
/**
 标题行间距 默认0
 */
@property (nonatomic,assign) CGFloat menuLineSpacing;
/**
 标题内容插入量 默认UIEdgeInsetsZero
 */
@property (nonatomic,assign) UIEdgeInsets menuContentInset;
/**
 未选中的字号 默认14
 */
@property (nonatomic,assign) CGFloat menuNormalTitleFontSize;
/**
 选中的字号 默认17
 */
@property (nonatomic,assign) CGFloat menuSelectTitleFontSize;
/**
 字体粗细 默认正常体
 */
@property (nonatomic,assign) BKSliderMenuTitleFontWeight menuTitleFontWeight;
/**
 未选中的颜色 默认[UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6]
 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 */
@property (nonatomic,strong) UIColor * menuNormalTitleColor;
/**
 选中的颜色 默认[UIColor colorWithRed:0 green:0 blue:0 alpha:1]
 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 */
@property (nonatomic,strong) UIColor * menuSelectTitleColor;

#pragma mark - 设置menu的临时属性(刷新后失效)

/**
 设置menu的临时属性(刷新后失效)

 @param normalFontSize 默认字号
 @param selectFontSize 选中字号
 @param normalColor 默认颜色
 @param selectColor 选中颜色
 @param switchingIndex 切换中的index
 @param leavingIndex 离开中的index
 @param percentage 百分比
 */
-(void)settingTempMenuTitleNormalFontSize:(CGFloat)normalFontSize selectFontSize:(CGFloat)selectFontSize normalColor:(UIColor*)normalColor selectColor:(UIColor*)selectColor switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

#pragma mark - 滑动sliderView的方法

/**
 滚动sliderView

 @param collectionView sliderView
 */
-(void)scrollCollectionView:(UICollectionView*)collectionView;

#pragma mark - 获取可见的menu

/**
 获取可见的menu

 @return menu数组
 */
-(NSArray<BKSliderMenu*> *)getVisibleMenu;

#pragma mark - 获取全部的menu属性

/**
 获取全部的menu属性

 @return menu属性数组
 */
-(NSArray<BKSliderMenuPropertyModel*> *)getTotalMenuProperty;

@end

NS_ASSUME_NONNULL_END
