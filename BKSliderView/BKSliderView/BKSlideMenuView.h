//
//  BKSlideMenuView.h
//
//  Created on 16/2/3.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BKSlideMenuView;
@class BKSlideView;

typedef NS_ENUM(NSUInteger, BKSlideMenuViewTitleWidthStyle) {
    BKSlideMenuViewTitleWidthStyleDefault = 0,             // 按照字的宽度 + 字左右设定的宽度
    BKSlideMenuViewTitleWidthStyleSame                     // 每个title的宽度一样
};

typedef NS_ENUM(NSUInteger, BKSlideMenuViewChangeStyle) {
    BKSlideMenuViewChangeStyleDefault = 0,
    BKSlideMenuViewChangeStyleCenter
};

typedef NS_OPTIONS(NSUInteger, BKSlideMenuViewSelectStyle) {
    BKSlideMenuViewSelectStyleNone = 0,                     //无效果
    BKSlideMenuViewSelectStyleHaveLine = 1 << 0,            //有线
    BKSlideMenuViewSelectStyleChangeFont = 1 << 1,          //选中的字体会变大
    BKSlideMenuViewSelectStyleChangeColor = 1 << 2,         //选中的字体颜色会有变化 未改动是灰色 normal 时颜色透明度为 0.6
    BKSlideMenuViewSelectStyleCustom = 1 << 3               //自定义选中的View 此选项与 BKSlideMenuViewSelectStyleHaveLine冲突 选择此项不能选择BKSlideMenuViewSelectStyleHaveLine 选择此项时动画跟BKSlideMenuViewSelectStyleHaveLine效果一样 但是selectView需要自定义 此时selectView跟 第一个选中的menuTitle大小一样 此时可以在 selectView 上添加任何 UI来做标记 (注意 不论选择哪个menuTitle selectView的大小是跟menuTitle的大小一样)
};

@protocol BKSlideMenuViewDelegate <NSObject>

@optional

/**
 *     改变selectView 实现的代理
 *     作用 自定义selectView
 **/
-(void)modifyChooseSelectView:(UIView*)selectView;

/**
 *     当selectView的frame改变时 修改自定义selectView 中自定义view的属性
 **/
-(void)changeElementInSelectView:(UIView*)selectView;

@required

/**
 *     SlideMenuView选择 滑动到对应SlideView
 *     index 选中当前 slideView 第index的View
 **/
-(void)selectMenuSlide:(BKSlideMenuView*)slideMenuView relativelyViewWithViewIndex:(NSInteger)index;

@end

@interface BKSlideMenuView : UITableView

/**
 *     自定义代理
 **/
@property (nonatomic,assign) id <BKSlideMenuViewDelegate>customDelegate;

/**
 *     创建方法 titleArray 是 menu title 数组
 **/
-(instancetype)initWithFrame:(CGRect)frame menuTitleArray:(NSArray*)titleArray;

/**
 *     menu title 数组
 **/
@property (nonatomic,strong,readonly) NSArray * menuTitleArray;

/**
 *     每一个cell的宽度 数组
 **/
@property (nonatomic,strong,readonly) NSArray * rowHeightArr;

/**
 *     每一个cell的左边起始坐标 数组
 **/
@property (nonatomic,strong,readonly) NSArray * rowYArr;

/**
 *     选中的View
 **/
@property (nonatomic,strong) UIView * selectView;

/**
 *     menuTitle 宽度格式
 **/
@property (nonatomic,assign) BKSlideMenuViewTitleWidthStyle titleWidthStyle;

/**
 *     变换格式 不做改动是Default
 **/
@property (nonatomic,assign) BKSlideMenuViewChangeStyle changeStyle;

/**
 *     选中的格式 不做改动时为  BKSlideMenuViewSelectStyleHaveLine | BKSlideMenuViewSelectStyleChangeFont | BKSlideMenuViewSelectStyleChangeColor
       可以自定义 BKSlideMenuViewSelectStyleCustom 自定义需实现 (可选) 1、自定义 selectView  2、实现自定义代理方法 changeToChooseSelectView 再该方法中自定义 selectView
 **/
@property (nonatomic,assign) BKSlideMenuViewSelectStyle selectStyle;

/**
 *     未选中的Title 的字号
 **/
@property (nonatomic,strong) UIFont * normalMenuTitleFont;

/**
 *     选中的Title 的字号
 **/
@property (nonatomic,strong) UIFont * selectMenuTitleFont;

/**
 *     未选中的Title字 的颜色
 *     设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 **/
@property (nonatomic,strong) UIColor * normalMenuTitleColor;

/**
 *     选中的Title字 的颜色
 *     设置格式必须是 [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:(CGFloat) alpha:(CGFloat)]
 **/
@property (nonatomic,strong) UIColor * selectMenuTitleColor;

/**
 *     改变选中
 **/
@property (nonatomic,assign) NSInteger selectNum;

/**
 *     选BKSlideMenuViewTitleWidthStyleDefault时 该值是两个menuTitle 中间的距离 默认是20
 *     选BKSlideMenuViewTitleWidthStyleSame时 该值是每个menuTitle的宽度 默认100
 **/
@property (nonatomic,assign) CGFloat menuTitleLength;


/**
 *     随着 SlideView 滑动的距离滑动
 **/
-(void)scrollWith:(BKSlideView*)slideView;

/**
 *     SlideView 结束滑动
 **/
-(void)endScrollWith:(BKSlideView*)slideView;

@end
