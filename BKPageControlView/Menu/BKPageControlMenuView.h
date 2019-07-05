//
//  BKPageControlMenuView.h
//  BKPageControlView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPageControlMenu.h"
#import "BKPageControlMenuPropertyModel.h"
@class BKPageControlMenuView;

typedef NS_OPTIONS(NSUInteger, BKPageControlMenuSelectStyle) {
    BKPageControlMenuSelectStyleNone = 0,                    //无效果
    BKPageControlMenuSelectStyleDisplayLine = 1 << 0,        //显示底部选中的线
    BKPageControlMenuSelectStyleChangeColor = 1 << 1,        //选中的字体颜色会有变化
    BKPageControlMenuSelectStyleChangeFont = 1 << 2          //选中的字体大小会有变化
};

typedef NS_ENUM(NSUInteger, BKPageControlMenuTitleFontWeight) {
    BKPageControlMenuTitleFontWeightLight,                     //细体
    BKPageControlMenuTitleFontWeightRegular,                   //正常体
    BKPageControlMenuTitleFontWeightMedium,                    //粗体
};

typedef NS_ENUM(NSUInteger, BKPageControlMenuSelectViewStyle) {
    BKPageControlMenuSelectViewStyleFollowMenuTitleWidth,      //随title的宽变化
    BKPageControlMenuSelectViewStyleConstantWidth              //恒定宽
};

@protocol BKPageControlMenuViewDelegate <NSObject>

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
 设置menu上的icon和选中的icon

 @param menu menu
 @param iconImageView icon
 @param selectIconImageView 选中的icon
 @param index 索引
 */
-(void)menu:(BKPageControlMenu * _Nonnull)menu settingIconImageView:(nullable UIImageView*)iconImageView selectIconImageView:(nullable UIImageView*)selectIconImageView atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlMenuView : UIView

/**
 代理
 */
@property (nonatomic,weak) id<BKPageControlMenuViewDelegate> delegate;
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
 菜单标题底部的线选中样式 默认BKPageControlMenuSelectViewStyleFollowMenuTitleWidth
 */
@property (nonatomic,assign) BKPageControlMenuSelectViewStyle selectViewStyle;
/**
 菜单标题底部的线恒定宽 默认15
 当menuSelectViewStyle == BKPageControlMenuSelectViewStyleConstantWidth有效
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
 等分宽度,为0时随标题长度而改变 默认0
 */
@property (nonatomic,assign) CGFloat menuEqualDivisionW;
/**
 选中的格式
 默认为 BKPageControlMenuSelectStyleDisplayLine | BKPageControlMenuSelectStyleChangeColor
 */
@property (nonatomic,assign) BKPageControlMenuSelectStyle menuSelectStyle;
/**
 间距 默认20  当menuEqualDivisionW!=0时有效
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
@property (nonatomic,assign) BKPageControlMenuTitleFontWeight menuTitleFontWeight;
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
-(NSArray<BKPageControlMenu*> *)getVisibleMenu;

#pragma mark - 获取全部的menu属性

/**
 获取全部的menu属性

 @return menu属性数组
 */
-(NSArray<BKPageControlMenuPropertyModel*> *)getTotalMenuProperty;

@end

NS_ASSUME_NONNULL_END
