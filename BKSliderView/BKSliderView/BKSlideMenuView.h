//
//  BKSlideMenuView.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSlideMenu.h"

typedef NS_OPTIONS(NSUInteger, BKSlideMenuSelectStyle) {
    BKSlideMenuSelectStyleNone = 0,                    //无效果
    BKSlideMenuSelectStyleDisplayLine = 1 << 0,        //显示底部选中的线
    BKSlideMenuSelectStyleChangeColor = 1 << 1,        //选中的字体颜色会有变化
    BKSlideMenuSelectStyleChangeFont = 1 << 2          //选中的字体大小会有变化
};

typedef NS_ENUM(NSUInteger, BKSlideMenuTypesetting) {
    BKSlideMenuTypesettingEqualSpace = 0,              //间距相等
    BKSlideMenuTypesettingEqualWidth                   //menu等宽
};

NS_ASSUME_NONNULL_BEGIN

@interface BKSlideMenuView : UIView

/**
 导航标题数组
 */
@property (nonatomic,copy) NSArray * titles;
/**
 当前选中索引 从0开始
 (selectIndex >= [titles count] - 1 时 selectIndex = [titles count] - 1)
 */
@property (nonatomic,assign) NSUInteger selectIndex;

#pragma mark - 导航视图

/**
 导航内容视图
 */
@property (nonatomic,strong) UIScrollView * contentView;
/**
 导航内容视图底部分割线
 */
@property (nonatomic,strong) UIImageView * bottomLine;

#pragma mark - 选中导航的线

/**
 选中menu底部的线 默认高度2 距底部距离0 颜色为[UIColor blackColor] cornerRadius高度一半
 */
@property (nonatomic,strong) UIView * selectView;

#pragma mark - 导航视图设置

/**
 menu排版 默认BKSlideMenuTypesettingEqualSpace
 选BKSlideMenuTypesettingEqualSpace时参数menuSpace有效
 选BKSlideMenuTypesettingEqualWidth时 例menu有3个时menu的宽为BKSlideMenuView.width/3 间距为0
 */
@property (nonatomic,assign) BKSlideMenuTypesetting menuTypesetting;
/**
 间距 默认20
 */
@property (nonatomic,assign) CGFloat menuSpace;
/**
 标题行数 默认1行
 */
@property (nonatomic,assign) CGFloat menuNumberOfLines;
/**
 选中的格式
 默认为 BKSlideMenuSelectStyleDisplayLine | BKSlideMenuSelectStyleChangeColor | BKSlideMenuSelectStyleChangeFont
 */
@property (nonatomic,assign) BKSlideMenuSelectStyle menuSelectStyle;
/**
 未选中的字号 默认14
 */
@property (nonatomic,assign) CGFloat normalMenuTitleFontSize;
/**
 选中的字号 默认17
 */
@property (nonatomic,assign) CGFloat selectMenuTitleFontSize;
/**
 未选中的颜色 默认[UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6]
 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 */
@property (nonatomic,strong) UIColor * normalMenuTitleColor;
/**
 选中的颜色 默认[UIColor colorWithRed:0 green:0 blue:0 alpha:1]
 设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 */
@property (nonatomic,strong) UIColor * selectMenuTitleColor;
/**
 修改导航视图的frame
 */
@property (nonatomic,copy) void (^changeMenuViewFrameCallBack)(void);
/**
 点击menu切换选取index回调
 */
@property (nonatomic,copy) void (^switchSelectIndexCallBack)(NSUInteger selectIndex);
/**
 点击menu切换选取index动画结束回调
 */
@property (nonatomic,copy) void (^switchSelectIndexCompleteCallBack)(void);

#pragma mark - 导航视图刷新回调

@property (nonatomic,copy) void (^refreshMenuUICallBack)(BKSlideMenuView * menuView);

#pragma mark - 滑动slideView的方法

/**
 滚动slideView

 @param collectionView slideView
 */
-(void)scrollCollectionView:(UICollectionView*)collectionView;

#pragma mark - 获取可见的menu

/**
 获取可见的menu

 @return menu数组
 */
-(NSArray<BKSlideMenu*>*)getVisibleMenu;

@end

NS_ASSUME_NONNULL_END
