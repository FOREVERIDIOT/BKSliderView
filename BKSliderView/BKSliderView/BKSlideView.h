//
//  BKSlideView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define SLIDE_MENU_VIEW_HEIGHT 45
#define DEFAULT_SELECTVIEW_HEIGHT 2

#define TITLE_ADD_GAP 20

#define NORMAL_TITLE_FONT 14.0f
#define FONT_GAP 1.1

#define NORMAL_TITLE_COLOR [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6]
#define SELECT_TITLE_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

#import <UIKit/UIKit.h>
@class BKSlideView;

typedef NS_ENUM(NSUInteger, BKSlideMenuViewChangeStyle) {
    SlideMenuViewChangeStyleDefault = 0,
    SlideMenuViewChangeStyleCenter
};

typedef NS_OPTIONS(NSUInteger, BKSlideMenuViewSelectStyle) {
    SlideMenuViewSelectStyleNone = 0,                     //无效果
    SlideMenuViewSelectStyleHaveLine = 1 << 0,            //有线
    SlideMenuViewSelectStyleChangeFont = 1 << 1,          //选中的字体会变大
    SlideMenuViewSelectStyleChangeColor = 1 << 2         //选中的字体颜色会有变化 未改动是灰色 normal 时颜色透明度为 0.6
};

@interface BKSlideView : UIView

#pragma mark - 显示的View

/**
 *  基础view
 */
@property (nonatomic,strong) UICollectionView * slideView;

#pragma mark - 显示的选取View

/**
 *  基础 selectScrollview
 */
@property (nonatomic,strong) UIScrollView * slideMenuView;

/**
 *     从1开始 目前选中的第几个,也可以赋值更改选中(超过数组最大值无效)
 */
@property (nonatomic,assign) NSInteger selectIndex;

/**
 *     menuTitle 宽度大小 设置后所有menuTitle的宽度为设置宽度
 */
@property (nonatomic,assign) CGFloat menuTitleWidth;

/**
 *     变换格式 不做改动是Default
 */
@property (nonatomic,assign) BKSlideMenuViewChangeStyle slideMenuViewChangeStyle;

/**
 *     选中的格式 不做改动时为  SlideMenuViewSelectStyleHaveLine | SlideMenuViewSelectStyleChangeFont | SlideMenuViewSelectStyleChangeColor
 */
@property (nonatomic,assign) BKSlideMenuViewSelectStyle slideMenuViewSelectStyle;

/**
 *     未选中的Title 的字号
 */
@property (nonatomic,strong) UIFont * normalMenuTitleFont;

/**
 *     选中的Title 的大小是未选中的字号的倍数 默认1.1
 */
@property (nonatomic,assign) CGFloat fontGap;

/**
 *     未选中的Title字 的颜色
 *     设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 */
@property (nonatomic,strong) UIColor * normalMenuTitleColor;

/**
 *     选中的Title字 的颜色
 *     设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 */
@property (nonatomic,strong) UIColor * selectMenuTitleColor;

#pragma mark - 方法

/**
 *     创建方法
 */
-(instancetype)initWithFrame:(CGRect)frame vcArray:(NSArray*)vcArray;

/**
 *     移动 SlideView 至第 index 页
 */
-(void)rollSlideViewToIndexView:(NSInteger)index;


@end
