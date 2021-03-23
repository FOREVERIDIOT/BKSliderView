//
//  BKPageControl.m
//  BKPageControlView
//
//  Created by BIKE on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#import "BKPageControl.h"
#import "BKPageControlMenuModel.h"
#import "BKPageControlView.h"
#import "BKPageControlSelectLine.h"
#import "UIView+BKPageControlView.h"

typedef NS_ENUM(NSUInteger, BKPageControlContentScrollDirection) {
    BKPageControlContentScrollDirectionLeft = 0,
    BKPageControlContentScrollDirectionRight
};

NSString * const kBKPageControlMenuID = @"kBKPageControlMenuID";
const float kSelectLineAnimateTimeInterval = 0.3;

@interface BKPageControl()<UIScrollViewDelegate>

/// 之前内容滑动偏移量
@property (nonatomic,assign) CGFloat lastContentOffsetX;
/// 滑动方向
@property (nonatomic,assign) BKPageControlContentScrollDirection scrollDirection;

/// 保存的选中字体字号
@property (nonatomic,assign) CGFloat tempMenuSelectTitleFontSize;
/// menu属性
@property (nonatomic,strong) BKPageControlMenuModel * menuModel;
/// 选中menu底部的线
@property (nonatomic,strong) BKPageControlSelectLine * selectLine;

@end

@implementation BKPageControl
@synthesize selectIndex = _selectIndex;

#pragma mark - 属性

-(void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self reloadContentView];
}

-(void)setLrInset:(CGFloat)lrInset
{
    _lrInset = lrInset;
    [self reloadContentView];
}

-(void)setContentViewWidth:(CGFloat)contentViewWidth
{
    _contentViewWidth = contentViewWidth;
    [self layoutSubviews];
}

-(void)setSelectIndex:(NSUInteger)selectIndex animated:(BOOL)animated
{
    [self setSelectIndex:selectIndex animated:animated completion:nil];
}

-(void)setSelectIndex:(NSUInteger)selectIndex animated:(BOOL)animated completion:(nullable void(^)(void))completion
{
    [self setSelectIndex:selectIndex animation:^BOOL{
        return animated;
    } completion:completion];
}

-(void)setSelectIndex:(NSUInteger)selectIndex animation:(nullable BOOL(^)(void))animation completion:(nullable void(^)(void))completion
{
    if (_selectIndex == selectIndex) {
        return;
    }else if (selectIndex > [self.titles count] - 1) {
        _selectIndex = [self.titles count] - 1;
    }else {
        _selectIndex = selectIndex;
    }
    
    [self reloadContentView];
    
    if (animation && animation()) {
        [UIView animateWithDuration:kSelectLineAnimateTimeInterval animations:^{
            if (animation) {
                animation();
            }
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSelectLineAnimateTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }else {
        if (completion) {
            completion();
        }
    }
}

-(void)setFrame:(CGRect)frame
{
    if (CGRectEqualToRect(self.frame, frame)) {
        return;
    }
    [super setFrame:frame];
    
    self.contentView.frame = CGRectMake(0, 0, self.width, self.height);
    self.bottomLine.y = self.height - self.bottomLine.height;
    self.selectLine.y = self.height - self.selectLine.height - self.selectLineBottomMargin;
    
    if ([self.delegate respondsToSelector:@selector(changeMenuViewFrame)]) {
        [self.delegate changeMenuViewFrame];
    }
    
    [self reloadContentView];
}

#pragma mark - 菜单设置

-(void)setMenuEqualDivisionW:(CGFloat)menuEqualDivisionW
{
    _menuEqualDivisionW = menuEqualDivisionW;
    [self reloadContentView];
}

-(void)setMenuSelectStyle:(BKPageControlMenuSelectStyle)menuSelectStyle
{
    _menuSelectStyle = menuSelectStyle;
    
    if (_menuSelectStyle & BKPageControlMenuSelectStyleChangeColor) {
        
    }else {
        self.menuSelectTitleColor = self.menuNormalTitleColor;
    }
    
    if (_menuSelectStyle & BKPageControlMenuSelectStyleChangeFont) {
        self.menuSelectTitleFontSize = self.tempMenuSelectTitleFontSize;
    }else {
        self.menuSelectTitleFontSize = self.menuNormalTitleFontSize;
    }
    
    if (_menuSelectStyle & BKPageControlMenuSelectStyleDisplayLine) {
        self.selectLine.hidden = NO;
    }else {
        self.selectLine.hidden = YES;
    }
    
    if (_menuSelectStyle & BKPageControlMenuSelectStyleDisplayBgView) {
        
    }else {
        self.menuNormalTitleBgColor = nil;
        self.menuSelectTitleBgColor = nil;
        self.menuTitleBgContentInset = UIEdgeInsetsZero;
        self.menuTitleBgAngle = 0;
    }
    
    [self reloadContentView];
}

-(void)setMenuSpace:(CGFloat)menuSpace
{
    _menuSpace = menuSpace;
    [self reloadContentView];
}

-(void)setMenuNumberOfLines:(CGFloat)menuNumberOfLines
{
    _menuNumberOfLines = menuNumberOfLines;
    [self reloadContentView];
}

-(void)setMenuLineSpacing:(CGFloat)menuLineSpacing
{
    _menuLineSpacing = menuLineSpacing;
    [self reloadContentView];
}

-(void)setMenuContentInset:(UIEdgeInsets)menuContentInset
{
    _menuContentInset = menuContentInset;
    [self reloadContentView];
}

-(void)setMenuNormalTitleFontSize:(CGFloat)menuNormalTitleFontSize
{
    _menuNormalTitleFontSize = menuNormalTitleFontSize;
    if (_menuSelectStyle & BKPageControlMenuSelectStyleChangeFont) {
        
    }else {
        _menuSelectTitleFontSize = _menuNormalTitleFontSize;
    }
    [self reloadContentView];
}

-(void)setMenuSelectTitleFontSize:(CGFloat)menuSelectTitleFontSize
{
    _tempMenuSelectTitleFontSize = menuSelectTitleFontSize;
    if (_menuSelectStyle & BKPageControlMenuSelectStyleChangeFont) {
        _menuSelectTitleFontSize = menuSelectTitleFontSize;
    }else {
        _menuSelectTitleFontSize = self.menuNormalTitleFontSize;
    }
    [self reloadContentView];
}

-(void)setMenuTitleFontWeight:(BKPageControlMenuTitleFontWeight)menuTitleFontWeight
{
    _menuTitleFontWeight = menuTitleFontWeight;
    [self reloadContentView];
}

-(void)setMenuNormalTitleColor:(UIColor *)menuNormalTitleColor
{
    _menuNormalTitleColor = menuNormalTitleColor;
    if (self.menuSelectStyle & BKPageControlMenuSelectStyleChangeColor) {
        
    }else {
        _menuSelectTitleColor = _menuNormalTitleColor;
    }
    [self reloadContentView];
}

-(void)setMenuSelectTitleColor:(UIColor *)menuSelectTitleColor
{
    if (self.menuSelectStyle & BKPageControlMenuSelectStyleChangeColor) {
        _menuSelectTitleColor = menuSelectTitleColor;
    }else {
        _menuSelectTitleColor = self.menuNormalTitleColor;
    }
    [self reloadContentView];
}

-(void)setMenuNormalTitleBgColor:(UIColor *)menuNormalTitleBgColor
{
    if (_menuSelectStyle & BKPageControlMenuSelectStyleDisplayBgView) {
        _menuNormalTitleBgColor = menuNormalTitleBgColor;
    }else {
        _menuNormalTitleBgColor = nil;
    }
    [self reloadContentView];
}

-(void)setMenuSelectTitleBgColor:(UIColor *)menuSelectTitleBgColor
{
    if (_menuSelectStyle & BKPageControlMenuSelectStyleDisplayBgView) {
        _menuSelectTitleBgColor = menuSelectTitleBgColor;
    }else {
        _menuSelectTitleBgColor = nil;
    }
    [self reloadContentView];
}

-(void)setMenuTitleBgContentInset:(UIEdgeInsets)menuTitleBgContentInset
{
    if (_menuSelectStyle & BKPageControlMenuSelectStyleDisplayBgView) {
        _menuTitleBgContentInset = menuTitleBgContentInset;
    }else {
        _menuTitleBgContentInset = UIEdgeInsetsZero;
    }
    [self reloadContentView];
}

-(void)setMenuTitleBgAngle:(CGFloat)menuTitleBgAngle
{
    if (_menuSelectStyle & BKPageControlMenuSelectStyleDisplayBgView) {
        _menuTitleBgAngle = menuTitleBgAngle;
    }else {
        _menuTitleBgAngle = 0;
    }
    [self reloadContentView];
}

#pragma mark - 选中导航的线

-(void)setSelectLineStyle:(BKPageControlMenuSelectLineStyle)selectLineStyle
{
    _selectLineStyle = selectLineStyle;
    if (_selectLine) {
        [self adjustSelectLinePosition];
    }
}

-(void)setSelectLineConstantW:(CGFloat)selectLineConstantW
{
    _selectLineConstantW = selectLineConstantW;
    if (_selectLine) {
        [self adjustSelectLinePosition];
    }
}

-(void)setSelectLineHeight:(CGFloat)selectLineHeight
{
    _selectLineHeight = selectLineHeight;
    if (_selectLine) {
        _selectLine.height = _selectLineHeight;
        _selectLine.layer.cornerRadius = _selectLine.height/2.0f;
    }
}

-(void)setSelectLineBottomMargin:(CGFloat)selectLineBottomMargin
{
    _selectLineBottomMargin = selectLineBottomMargin;
    if (_selectLine) {
        _selectLine.y = self.height - _selectLine.height - _selectLineBottomMargin;
    }
}

-(void)setSelectLineBgColor:(UIColor *)selectLineBgColor
{
    _selectLineBgColor = selectLineBgColor;
    _selectLineBgGradientColor = nil;
    if (_selectLine) {
        _selectLine.bgColor = _selectLineBgColor;
    }
}

-(void)setSelectLineBgGradientColor:(NSArray<UIColor *> *)selectLineBgGradientColor
{
    _selectLineBgGradientColor = selectLineBgGradientColor;
    _selectLineBgColor = nil;
    if (_selectLine) {
        _selectLine.colors = _selectLineBgGradientColor;
    }
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
        
        [self reloadContentView];
    }
    return self;
}

-(void)initData
{
    self.selectLineStyle = BKPageControlMenuSelectLineStyleFollowMenuTitleWidth;
    self.selectLineConstantW = 15;
    self.selectLineHeight = 2;
    self.selectLineBottomMargin = 0;
    self.selectLineBgColor = [UIColor blackColor];
    
    self.menuEqualDivisionW = 0;
    self.menuSelectStyle = BKPageControlMenuSelectStyleDisplayLine | BKPageControlMenuSelectStyleChangeColor;
    self.menuSpace = 20;
    self.menuNumberOfLines = 1;
    self.menuLineSpacing = 0;
    self.menuContentInset = UIEdgeInsetsZero;
    self.menuNormalTitleFontSize = 14;
    self.menuSelectTitleFontSize = 17;
    self.tempMenuSelectTitleFontSize = 17;
    self.menuTitleFontWeight = BKPageControlMenuTitleFontWeightRegular;
    self.menuNormalTitleColor = [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6];
    self.menuSelectTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.menuNormalTitleBgColor = nil;
    self.menuSelectTitleBgColor = nil;
    self.menuTitleBgContentInset = UIEdgeInsetsZero;
    self.menuTitleBgAngle = 0;
}

-(void)initUI
{
    [self addSubview:self.contentView];
    [self addSubview:self.bottomLine];
    [self.contentView addSubview:self.selectLine];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(0, 0, self.contentViewWidth > 0 ? self.contentViewWidth : self.width, self.height);
    self.bottomLine.frame = CGRectMake(0, self.height - BK_ONE_PIXEL, self.width, BK_ONE_PIXEL);
    self.selectLine.frame = CGRectMake(self.selectLine.x, self.height - self.selectLineHeight - self.selectLineBottomMargin, self.selectLine.width, self.selectLineHeight);
}

#pragma mark - initUI

-(UIScrollView*)contentView
{
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _contentView;
}

-(UIImageView*)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - BK_ONE_PIXEL, self.width, BK_ONE_PIXEL)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1];
    }
    return _bottomLine;
}

-(BKPageControlSelectLine*)selectLine
{
    if (!_selectLine) {
        _selectLine = [[BKPageControlSelectLine alloc] initWithFrame:CGRectMake(0, self.contentView.height - self.selectLineHeight - self.selectLineBottomMargin, 0, self.selectLineHeight)];
        _selectLine.hidden = YES;
        _selectLine.bgColor = self.selectLineBgColor;
        _selectLine.layer.cornerRadius = _selectLine.height/2.0f;
        _selectLine.clipsToBounds = YES;
    }
    return _selectLine;
}

#pragma mark - 创建菜单

-(BKPageControlMenuModel*)menuModel
{
    if (!_menuModel) {
        _menuModel = [[BKPageControlMenuModel alloc] init];
    }
    return _menuModel;
}

-(BKPageControlMenu*)createMenu
{
    BKPageControlMenu * menu = [[BKPageControlMenu alloc] init];
    [menu assignTitle:nil textColor:self.menuNormalTitleColor font:[self getMenuFontSize:self.menuNormalTitleFontSize] numberOfLines:self.menuNumberOfLines lineSpacing:self.menuLineSpacing];
    menu.contentInset = self.menuContentInset;
    [menu addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
    return menu;
}

-(void)menuClick:(BKPageControlMenu*)menu
{
    [[[[UIApplication sharedApplication] delegate] window] endEditing:YES];
    
    if (self.selectIndex == menu.displayIndex) {
        return;
    }
    
    NSUInteger leaveIndex = self.selectIndex;
    NSUInteger selectIndex = menu.displayIndex;
    
    if ([self.delegate respondsToSelector:@selector(menuView:willLeaveIndex:)]) {
        [self.delegate menuView:self willLeaveIndex:leaveIndex];
    }
    
    if ([self.delegate respondsToSelector:@selector(menuView:switchingSelectIndex:leavingIndex:percentage:)]) {
        [self.delegate menuView:self switchingSelectIndex:selectIndex leavingIndex:leaveIndex percentage:1];
    }
    
    if ([self.delegate respondsToSelector:@selector(menuView:switchIndex:)]) {
        [self.delegate menuView:self switchIndex:selectIndex];
    }
}

-(BKPageControlMenu*)dequeueReusableMenuAtIndex:(NSUInteger)index
{
    BKPageControlMenu * menu = nil;
    for (BKPageControlMenu * m in self.menuModel.visible) {
        if (m.displayIndex == index) {
            menu = m;
        }
    }
    //如果menu已经显示 则返回显示的menu 如果没有显示创建menu
    if (!menu) {
        if ([self.menuModel.cache count] == 0) {//没有则创建
            menu = [self createMenu];
        }else {//有则复用
            menu = [self.menuModel.cache firstObject];
        }
    }
    return menu;
}

-(UIFont*)getMenuFontSize:(CGFloat)fontSize
{
    switch (self.menuTitleFontWeight) {
        case BKPageControlMenuTitleFontWeightLight:
        {
            if (@available(iOS 8.2, *)) {
                return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
            }else {
                return [UIFont italicSystemFontOfSize:fontSize];
            }
        }
            break;
        case BKPageControlMenuTitleFontWeightRegular:
        {
            if (@available(iOS 8.2, *)) {
                return [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
            }else {
                return [UIFont systemFontOfSize:fontSize];
            }
        }
            break;
        case BKPageControlMenuTitleFontWeightMedium:
        {
            if (@available(iOS 8.2, *)) {
                return [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
            }else {
                return [UIFont boldSystemFontOfSize:fontSize];
            }
        }
            break;
    }
}

/// 显示可见的menu
-(void)displayMenu
{
    //显示区域
    CGRect displayRect = CGRectMake(self.contentView.contentOffset.x, 0, self.contentView.width, self.contentView.height);
    //滑出显示区域 删除
    NSArray * visible = [self.menuModel.visible copy];
    [visible enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!CGRectIntersectsRect(obj.frame, displayRect)) {
            [obj removeFromSuperview];
            [self.menuModel.visibleIndexs removeObject:@(obj.displayIndex)];
            [self.menuModel.visible removeObject:obj];
            [self.menuModel.cache addObject:obj];
        }
    }];
    //滑入显示区域 添加
    [self.menuModel.total enumerateObjectsUsingBlock:^(BKPageControlMenuPropertyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.rect, displayRect) && ![self.menuModel.visibleIndexs containsObject:@(idx)]) {
            BKPageControlMenu * menu = [self dequeueReusableMenuAtIndex:idx];
            [self assignDataForMenu:menu index:idx];
            [self.contentView addSubview:menu];
            [self.menuModel.visibleIndexs addObject:@(idx)];
            [self.menuModel.visible addObject:menu];
            [self.menuModel.cache removeObject:menu];
        }
    }];
    //防止快速滑动远距离menu执行removeFromSuperview没有删除掉 移除缓存所有显示menu
    [self.menuModel.cache enumerateObjectsUsingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

-(void)assignDataForMenu:(BKPageControlMenu*)menu index:(NSUInteger)index
{
    BKPageControlMenuPropertyModel * model = self.menuModel.total[index];
    
    menu.displayIndex = index;
    menu.frame = model.rect;
    [menu assignTitle:self.titles[index] textColor:model.color font:model.font numberOfLines:self.menuNumberOfLines lineSpacing:self.menuLineSpacing];
    menu.contentInset = self.menuContentInset;
    menu.titleBgViewColor = model.bgColor;
    menu.titleBgContentInset = self.menuTitleBgContentInset;
    menu.titleBgAngle = self.menuTitleBgAngle;
    
    if ([self.delegate respondsToSelector:@selector(menu:atIndex:)]) {
        [self.delegate menu:menu atIndex:index];
    }
}

#pragma mark - 刷新菜单

-(void)reloadContentView
{
    [self.menuModel.total removeAllObjects];
    [self.menuModel.visibleIndexs removeAllObjects];
    NSArray * visible = [self.menuModel.visible copy];
    [visible enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.menuModel.visible removeObject:obj];
        [self.menuModel.cache addObject:obj];
    }];
    
    CGRect lastRect = CGRectZero;
    for (int i = 0; i < [self.titles count]; i++) {
        NSString * title = self.titles[i];
        UIFont * font = nil;
        UIColor * color = nil;
        UIColor * bgColor = nil;
        if (self.selectIndex == i) {
            font = [self getMenuFontSize:self.menuSelectTitleFontSize];
            color = self.menuSelectTitleColor;
            bgColor = self.menuSelectTitleBgColor;
        }else {
            font = [self getMenuFontSize:self.menuNormalTitleFontSize];
            color = self.menuNormalTitleColor;
            bgColor = self.menuNormalTitleBgColor;
        }
        CGFloat width = [self calculateString:title settingHeight:self.contentView.height font:font].width + self.menuContentInset.left + self.menuContentInset.right;
        
        BKPageControlMenuPropertyModel * model = [[BKPageControlMenuPropertyModel alloc] init];
        model.color = color;
        model.font = font;
        model.bgColor = bgColor;
        if (self.menuEqualDivisionW == 0) {
            CGFloat x = (i == 0 ? self.lrInset : CGRectGetMaxX(lastRect)) + self.menuSpace;
            model.rect = CGRectMake(x, 0, width, self.contentView.height);
        }else {
            CGFloat x = i == 0 ? self.lrInset : CGRectGetMaxX(lastRect);
            model.rect = CGRectMake(x, 0, self.menuEqualDivisionW, self.contentView.height);
        }
        [self.menuModel.total addObject:model];
    
        lastRect = model.rect;
    }
    self.contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastRect) + self.lrInset + (self.menuEqualDivisionW == 0 ? self.menuSpace : 0), self.contentView.height);
    
    CGFloat maxOffsetX = self.contentView.contentSize.width - self.contentView.width;
    if (maxOffsetX > 0 && self.contentView.contentOffset.x > maxOffsetX) {
        self.contentView.contentOffset = CGPointMake(maxOffsetX, self.contentView.contentOffset.y);
    }
    
    [self displayMenu];
    [self adjustSelectLinePosition];
}

-(void)adjustSelectLinePosition
{
    [self.menuModel.visible enumerateObjectsUsingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.displayIndex == self.selectIndex) {
            [UIView animateWithDuration:kSelectLineAnimateTimeInterval animations:^{
                BKPageControlMenuPropertyModel * model = self.menuModel.total[obj.displayIndex];
                if (self.selectLineStyle == BKPageControlMenuSelectLineStyleFollowMenuTitleWidth) {
                    self.selectLine.width = model.rect.size.width;
                }else {
                    self.selectLine.width = self.selectLineConstantW;
                }
                self.selectLine.centerX = obj.centerX;
                //修改了selectLine的位置后 修改menuView的偏移量
                [self calcScrollContentOffsetAccordingToSelectLinePosition];
            }];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.contentView) {
        //加一个异步回归主线程方法 防止重用view执行动画
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayMenu];
        });
    }
}

#pragma mark - 内容视图滑动的方法

-(void)collectionViewDidScroll:(UICollectionView*)collectionView
{
    CGFloat offsetX = collectionView.contentOffset.x;//滑动偏移量x
    if (self.lastContentOffsetX == offsetX) {
        return;
    }
    NSUInteger displayIndex = 0;//当前主要显示的index
    NSUInteger item = 0;//collectionView最左边所在的item
    CGFloat page_offsetX = 0;//当页滑动的偏移量x
    CGFloat percentage = 0;//一页滑动的百分比
    if (collectionView.width != 0) {
        item = offsetX / collectionView.width;
        displayIndex = (offsetX + collectionView.width/2) / collectionView.width;
        page_offsetX = (CGFloat)((NSUInteger)offsetX % (NSUInteger)collectionView.width);
        percentage = page_offsetX / collectionView.width;
    }
    
    if (self.lastContentOffsetX > collectionView.contentOffset.x) {//上一次偏移量x > 目前偏移量 说明往右划
        self.scrollDirection = BKPageControlContentScrollDirectionRight;
    }else if (self.lastContentOffsetX < collectionView.contentOffset.x) {//上一次偏移量x < 目前偏移量 说明往左划
        self.scrollDirection = BKPageControlContentScrollDirectionLeft;
    }//上一次偏移量x == 目前偏移量 继续保持上一次
    
    //初始化开始索引 和 目标索引
    NSUInteger fromIndex, toIndex;
    if (percentage == 0) {
        if (self.scrollDirection == BKPageControlContentScrollDirectionRight) {
            toIndex = item;
            fromIndex = toIndex + 1;
        }else {
            toIndex = item;
            fromIndex = toIndex - 1;
        }
        percentage = 1;
    }else {
        if (self.scrollDirection == BKPageControlContentScrollDirectionRight) {
            toIndex = item;
            fromIndex = toIndex + 1;
            percentage = 1 - percentage;
        }else {
            fromIndex = item;
            toIndex = fromIndex + 1;
        }
    }
    
    [self changeSelectPropertyWithFromIndex:fromIndex toIndex:toIndex percentage:percentage];
    [UIView animateWithDuration:kSelectLineAnimateTimeInterval animations:^{
        [self calcScrollContentOffsetAccordingToSelectLinePosition];
    }];
    
    if ([self.delegate respondsToSelector:@selector(menuView:switchingSelectIndex:leavingIndex:percentage:)]) {
        [self.delegate menuView:self switchingSelectIndex:toIndex leavingIndex:fromIndex percentage:percentage];
    }
    
    self.lastContentOffsetX = collectionView.contentOffset.x;
}

-(void)collectionViewDidEndDecelerating:(UICollectionView*)collectionView
{
    CGFloat offsetX = collectionView.contentOffset.x;
    NSUInteger displayIndex = 0;
    if (collectionView.width != 0) {
        displayIndex = (offsetX + collectionView.width/2) / collectionView.width;
    }
    [self setSelectIndex:displayIndex animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(menuView:switchIndex:)]) {
        [self.delegate menuView:self switchIndex:self.selectIndex];
    }
}

#pragma mark - 滑动改变属性

/**
 滑动改变 字体颜色、大小、选中线位置

 @param fromIndex 来自index
 @param toIndex 至index
 @param percentage 当前页滑动百分比
 */
-(void)changeSelectPropertyWithFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex percentage:(CGFloat)percentage
{
    //没有数据 数组越界return 或者 isnan(percentage)
    if ([self.titles count] == 0 || fromIndex > [self.menuModel.total count] - 1 || toIndex > [self.menuModel.total count] - 1 || isnan(percentage)) {
        return;
    }
    
    //字体颜色
    UIColor * fromColor = [self calcColorWithFromColor:self.menuSelectTitleColor toColor:self.menuNormalTitleColor percentage:percentage isCalcFrom:YES];
    UIColor * toColor = [self calcColorWithFromColor:self.menuSelectTitleColor toColor:self.menuNormalTitleColor percentage:percentage isCalcFrom:NO];
    
    //字号
    CGFloat fontSizeChange = (self.menuSelectTitleFontSize - self.menuNormalTitleFontSize) * percentage;
    UIFont * fromFont = [self getMenuFontSize:self.menuSelectTitleFontSize - fontSizeChange];
    UIFont * toFont = [self getMenuFontSize:self.menuNormalTitleFontSize + fontSizeChange];
    
    //背景颜色
    UIColor * fromBgColor = [self calcColorWithFromColor:self.menuSelectTitleBgColor toColor:self.menuNormalTitleBgColor percentage:percentage isCalcFrom:YES];
    UIColor * toBgColor = [self calcColorWithFromColor:self.menuSelectTitleBgColor toColor:self.menuNormalTitleBgColor percentage:percentage isCalcFrom:NO];
    
    BKPageControlMenuPropertyModel * fromModel = self.menuModel.total[fromIndex];
    fromModel.color = fromColor;
    fromModel.font = fromFont;
    fromModel.bgColor = fromBgColor;
    [self.menuModel.total replaceObjectAtIndex:fromIndex withObject:fromModel];
    
    BKPageControlMenuPropertyModel * toModel = self.menuModel.total[toIndex];
    toModel.color = toColor;
    toModel.font = toFont;
    toModel.bgColor = toBgColor;
    [self.menuModel.total replaceObjectAtIndex:toIndex withObject:toModel];
    
    CGRect lastRect = CGRectZero;
    for (int i = 0; i < [self.titles count]; i++) {
        NSString * title = self.titles[i];
        BKPageControlMenuPropertyModel * model = self.menuModel.total[i];
        //大小
        CGFloat width = [self calculateString:title settingHeight:self.contentView.height font:model.font].width + self.menuContentInset.left + self.menuContentInset.right;
        if (self.menuEqualDivisionW == 0) {
            CGFloat x = (i == 0 ? self.lrInset : CGRectGetMaxX(lastRect)) + self.menuSpace;
            model.rect = CGRectMake(x, 0, width, self.contentView.height);
        }else {
            CGFloat x = i == 0 ? self.lrInset : CGRectGetMaxX(lastRect);
            model.rect = CGRectMake(x, 0, self.menuEqualDivisionW, self.contentView.height);
        }
        [self.menuModel.total replaceObjectAtIndex:i withObject:model];
        
        lastRect = model.rect;
    }
    self.contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastRect) + self.lrInset + (self.menuEqualDivisionW == 0 ? self.menuSpace : 0), self.contentView.height);
    //赋值
    [self.menuModel.visible enumerateObjectsUsingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKPageControlMenuPropertyModel * model = self.menuModel.total[obj.displayIndex];
        obj.frame = model.rect;
        [obj assignTitle:obj.text textColor:model.color font:model.font numberOfLines:obj.numberOfLines lineSpacing:obj.lineSpacing];
        obj.titleBgViewColor = model.bgColor;
    }];
    
    //修改menu属性后新的model 用于修改选中线的位置
    BKPageControlMenuPropertyModel * new_fromModel = self.menuModel.total[fromIndex];
    BKPageControlMenuPropertyModel * new_toModel = self.menuModel.total[toIndex];
    
    CGFloat fromCenterX = CGRectGetMidX(new_fromModel.rect);
    CGFloat fromWidth = new_fromModel.rect.size.width;
    CGFloat toCenterX = CGRectGetMidX(new_toModel.rect);
    CGFloat toWidth = new_toModel.rect.size.width;
    
    if (self.selectLineStyle == BKPageControlMenuSelectLineStyleFollowMenuTitleWidth) {
        self.selectLine.width = (toWidth - fromWidth) * percentage + fromWidth;
    }else {
        self.selectLine.width = self.selectLineConstantW;
    }
    self.selectLine.centerX = fromCenterX + (toCenterX - fromCenterX) * percentage;
}

/// 计算颜色变化
/// @param fromColor 变换前的颜色
/// @param toColor 变换后的颜色
/// @param percentage 百分比
/// @param isCalcFrom YES计算变换前的颜色 NO计算变换后的颜色
-(UIColor*)calcColorWithFromColor:(UIColor*)fromColor toColor:(UIColor*)toColor percentage:(CGFloat)percentage isCalcFrom:(BOOL)isCalcFrom
{
    CGFloat fromTitleR = [[fromColor valueForKey:@"redComponent"] floatValue];
    CGFloat fromTitleG = [[fromColor valueForKey:@"greenComponent"] floatValue];
    CGFloat fromTitleB = [[fromColor valueForKey:@"blueComponent"] floatValue];
    CGFloat fromTitleAlpha = [[fromColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat toTitleR = [[toColor valueForKey:@"redComponent"] floatValue];
    CGFloat toTitleG = [[toColor valueForKey:@"greenComponent"] floatValue];
    CGFloat toTitleB = [[toColor valueForKey:@"blueComponent"] floatValue];
    CGFloat toTitleAlpha = [[toColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat RChange = percentage * (fromTitleR - toTitleR);
    CGFloat GChange = percentage * (fromTitleG - toTitleG);
    CGFloat BChange = percentage * (fromTitleB - toTitleB);
    CGFloat alphaChange = percentage * (fromTitleAlpha - toTitleAlpha);
    
    UIColor * resultColor = nil;
    if (isCalcFrom) {
        resultColor = [UIColor colorWithRed:fromTitleR-RChange green:fromTitleG-GChange blue:fromTitleB-BChange alpha:fromTitleAlpha-alphaChange];
    }else {
        resultColor = [UIColor colorWithRed:toTitleR+RChange green:toTitleG+GChange blue:toTitleB+BChange alpha:toTitleAlpha+alphaChange];
    }
    return resultColor;
}

/**
 根据选中线的位置计算滑动偏移量(中心)
 */
-(void)calcScrollContentOffsetAccordingToSelectLinePosition
{
    //不能滚动return
    if (self.contentView.contentSize.width <= self.contentView.width) {
        return;
    }
    
    CGFloat selectLinePositionGaps = CGRectGetMaxX(self.selectLine.frame) - self.contentView.contentOffset.x;
    CGFloat left_right_Gap = (self.contentView.width - self.selectLine.width)/2.0f;
    if (selectLinePositionGaps > self.contentView.width - left_right_Gap) {
        CGFloat move = self.selectLine.x - left_right_Gap;
        if (move > self.contentView.contentSize.width - self.contentView.width) {
            move = self.contentView.contentSize.width - self.contentView.width;
        }
        [self.contentView setContentOffset:CGPointMake(move, 0) animated:NO];
    }else if (self.selectLine.x - self.contentView.contentOffset.x < left_right_Gap) {
        CGFloat move = self.selectLine.x - left_right_Gap;
        if (move < 0) {
            move = 0;
        }
        [self.contentView setContentOffset:CGPointMake(move, 0) animated:NO];
    }
}

#pragma mark - 文本计算

-(CGSize)calculateString:(NSString*)string settingHeight:(CGFloat)height font:(UIFont*)font
{
    if (!string || height <= 0 || !font) {
        return CGSizeZero;
    }
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    return rect.size;
}

#pragma mark - 公开方法

-(NSArray<BKPageControlMenu*> *)getVisibleMenu
{
    return [self.menuModel.visible copy];
}

-(NSArray<BKPageControlMenuPropertyModel*> *)getTotalMenuProperty
{
    return [self.menuModel.total copy];
}

@end
