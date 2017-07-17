//
//  BKSlideView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define SLIDE_MENU_VIEW_HEIGHT 45
#define DEFAULT_SELECTVIEW_HEIGHT 2

#define TITLE_ADD_GAP 30

#define NORMAL_TITLE_FONT 14.0f

#define NORMAL_TITLE_COLOR [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6]
#define SELECT_TITLE_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

#import <UIKit/UIKit.h>
@class BKSlideView;

typedef NS_OPTIONS(NSUInteger, BKSlideMenuViewSelectStyle) {
    SlideMenuViewSelectStyleNone = 0,                     //无效果
    SlideMenuViewSelectStyleHaveLine = 1 << 0,            //有线
    SlideMenuViewSelectStyleChangeColor = 1 << 1         //选中的字体颜色会有变化
};

@protocol BKSlideViewDelegate <NSObject>

@required

/**
 创建对应index的VC

 @param slideView BKSlideView
 @param index     索引 从0开始
 */
-(void)slideView:(BKSlideView*)slideView createVCWithIndex:(NSInteger)index;

@optional

/**
 目前所在VC的index

 @param slideView BKSlideView
 @param index     索引 从0开始
 */
-(void)slideView:(BKSlideView*)slideView nowShowSelectIndex:(NSInteger)index;

@end

@interface BKSlideView : UIView

@property (nonatomic,assign) id<BKSlideViewDelegate> delegate;

/**
 刷新slideMenuView
 */
-(void)reloadMenuView;

/**
 viewController数组
 */
@property (nonatomic,strong) NSArray * vcArray;

#pragma mark - 背景滚动视图

/**
 背景滚动视图(竖直方向)
 */
@property (nonatomic,strong) UIScrollView * bgScrollView;

#pragma mark - 头视图

/**
 头视图
 */
@property (nonatomic,strong) UIView * headerView;

#pragma mark - 显示的选取View

/**
 *  title滑动视图
 */
@property (nonatomic,strong) UIScrollView * slideMenuView;

/**
 *     选中的View
 */
@property (nonatomic,strong) UIView * selectView;

/**
 *     从1开始 目前选中的第几个,也可以赋值更改选中(超过数组最大值无效)
 */
@property (nonatomic,assign) NSInteger selectIndex;

/**
 *     menuTitle 宽度大小 设置后所有menuTitle的宽度为设置宽度
 */
@property (nonatomic,assign) CGFloat menuTitleWidth;

/**
 *     选中的格式 默认为  SlideMenuViewSelectStyleHaveLine | SlideMenuViewSelectStyleChangeColor
 */
@property (nonatomic,assign) BKSlideMenuViewSelectStyle slideMenuViewSelectStyle;

/**
 *     未选中的Title 的字号
 */
@property (nonatomic,strong) UIFont * normalMenuTitleFont;

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

#pragma mark - 滑动主视图

/**
 *  滑动主视图
 */
@property (nonatomic,strong) UICollectionView * slideView;

#pragma mark - 方法

/**
 *     创建方法
 */
-(instancetype)initWithFrame:(CGRect)frame vcArray:(NSArray*)vcArray;

/**
 *     移动 SlideView 至第 index 页 从0开始
 */
-(void)rollSlideViewToIndexView:(NSInteger)index;


@end



