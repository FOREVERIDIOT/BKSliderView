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
    SlideMenuViewSelectStyleChangeColor = 1 << 2,         //选中的字体颜色会有变化 未改动是灰色 normal 时颜色透明度为 0.6
    SlideMenuViewSelectStyleCustom = 1 << 3               //自定义选中的View 此选项与 SlideMenuViewSelectStyleHaveLine冲突 选择此项不能选择SlideMenuViewSelectStyleHaveLine 选择此项时动画跟SlideMenuViewSelectStyleHaveLine效果一样 但是selectView需要自定义 此时selectView跟 第一个选中的menuTitle大小一样 此时可以在 selectView 上添加任何 UI来做标记 (注意 不论选择哪个menuTitle selectView的大小是跟menuTitle的大小一样)
};

@protocol BKSlideViewDelegate <NSObject>

@required

/**
 *  创建UI
 *
 *  @param view  第几页上的view （创建UI在这里创建）
 *  @param index 第几页
 */
-(void)slideView:(BKSlideView*)slideView initInView:(UIView*)view atIndex:(NSInteger)index;

@optional

/**
 *     自定义selectView里view的内容 实现的代理
 *     作用 自定义selectView 在selectView中创建的view如果设置tag,此tag必须大于[menuTitleArray count]
 */
-(void)slideView:(BKSlideView*)slideView editSelectView:(UIView*)selectView;

/**
 *     当创建自定义selectView时 或 当selectView的frame改变时 修改自定义selectView 中自定义view的属性
 */
-(void)slideView:(BKSlideView*)slideView editSubInSelectView:(UIView*)selectView;

@end

@interface BKSlideView : UIView

#pragma mark - 自定义delegate

/**
 *  自定义delegate
 */
@property (nonatomic,assign) id <BKSlideViewDelegate>customDelegate;

/**
 *     menu title 数组
 */
@property (nonatomic,strong,readonly) NSArray * menuTitleArray;

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
 *     变换格式 不做改动是Default
 */
@property (nonatomic,assign) BKSlideMenuViewChangeStyle slideMenuViewChangeStyle;

/**
 *     选中的格式 不做改动时为  SlideMenuViewSelectStyleHaveLine | SlideMenuViewSelectStyleChangeFont | SlideMenuViewSelectStyleChangeColor
 可以自定义 SlideMenuViewSelectStyleCustom 自定义需实现 (可选) 1、自定义 selectView  2、实现自定义代理方法 editSelectView 和 editSubInSelectView 再该方法中自定义 selectView和selectView中View的frame
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
 *     创建方法 pageNum 是页数
 */
-(instancetype)initWithFrame:(CGRect)frame menuTitleArray:(NSArray*)titleArray delegate:(id<BKSlideViewDelegate>)customDelegate;

/**
 *     移动 SlideView 至第 index 页
 */
-(void)rollSlideViewToIndexView:(NSInteger)index;

/**
 *  获取当前显示View
 */
-(UIView*)getDisplayView;

@end
