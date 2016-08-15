//
//  BKSlideMenuView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BKSlideMenuView;
@class BKSlideView;

typedef NS_ENUM(NSUInteger, BKSlideMenuViewTitleWidthStyle) {
    SlideMenuViewTitleWidthStyleDefault = 0,             // 按照字的宽度 + 字左右设定的宽度
    SlideMenuViewTitleWidthStyleSame                     // 每个title的宽度一样
};

typedef NS_ENUM(NSUInteger, BKSlideMenuViewChangeStyle) {
    SlideMenuViewChangeStyleDefault = 0,
    SlideMenuViewChangeStyleCenter
};

typedef NS_OPTIONS(NSUInteger, BKSlideMenuViewSelectStyle) {
    SlideMenuViewSelectStyleNone = 0,                     //无效果
    SlideMenuViewSelectStyleHaveLine = 1 << 0,            //有线
    SlideMenuViewSelectStyleChangeFont = 1 << 1,          //选中的字体会变大
    SlideMenuViewSelectStyleChangeColor = 1 << 2,         //选中的字体颜色会有变化 未改动是灰色 normal 时颜色透明度为 0.6
    SlideMenuViewSelectStyleCustom = 1 << 3               //自定义选中的View 此选项与 BKSlideMenuViewSelectStyleHaveLine冲突 选择此项不能选择BKSlideMenuViewSelectStyleHaveLine 选择此项时动画跟BKSlideMenuViewSelectStyleHaveLine效果一样 但是selectView需要自定义 此时selectView跟 第一个选中的menuTitle大小一样 此时可以在 selectView 上添加任何 UI来做标记 (注意 不论选择哪个menuTitle selectView的大小是跟menuTitle的大小一样)
};

@protocol BKSlideMenuViewDelegate <NSObject>

@optional

/**
 *     改变selectView 实现的代理
 *     作用 自定义selectView
 */
-(void)modifyChooseSelectView:(UIView*)selectView;

/**
 *     当selectView的frame改变时 修改自定义selectView 中自定义view的属性
 */
-(void)changeElementInSelectView:(UIView*)selectView;

@required

/**
 *     SlideMenuView选择 滑动到对应SlideView
 *     index 选中当前 slideView 第index的View
 */
-(void)selectMenuSlide:(BKSlideMenuView*)slideMenuView relativelyViewWithViewIndex:(NSInteger)index;

@end

@interface BKSlideMenuView : UIScrollView

/**
 *     自定义代理
 */
@property (nonatomic,assign) id <BKSlideMenuViewDelegate>customDelegate;

/**
 *     创建方法 titleArray 是 menu title 数组
 */
-(instancetype)initWithFrame:(CGRect)frame menuTitleArray:(NSArray*)titleArray;

/**
 *     menu title 数组
 */
@property (nonatomic,strong,readonly) NSArray * menuTitleArray;

/**
 *     从1开始 目前选中的第几个,也可以赋值更改选中(超过数组最大值无效)
 */
@property (nonatomic,assign) NSInteger selectIndex;

/**
 *     选中的View
 */
@property (nonatomic,strong) UIView * selectView;

/**
 *     menuTitle 宽度格式
 */
@property (nonatomic,assign) BKSlideMenuViewTitleWidthStyle slideMenuViewTitleWidthStyle;

/**
 *     变换格式 不做改动是Default
 */
@property (nonatomic,assign) BKSlideMenuViewChangeStyle slideMenuViewChangeStyle;

/**
 *     选中的格式 不做改动时为  BKSlideMenuViewSelectStyleHaveLine | BKSlideMenuViewSelectStyleChangeFont | BKSlideMenuViewSelectStyleChangeColor
 可以自定义 BKSlideMenuViewSelectStyleCustom 自定义需实现 (可选) 1、自定义 selectView  2、实现自定义代理方法 changeToChooseSelectView 再该方法中自定义 selectView
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




/**
 *     随着 SlideView 滑动的距离滑动
 */
-(void)scrollWith:(UICollectionView*)slideView;

/**
 *     SlideView 结束滑动
 */
-(void)endScrollWith:(UICollectionView*)slideView;

@end
