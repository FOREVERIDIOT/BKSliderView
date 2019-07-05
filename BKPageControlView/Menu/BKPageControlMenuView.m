//
//  BKPageControlMenuView.m
//  BKPageControlView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#import "BKPageControlMenuView.h"
#import "UIView+BKPageControlView.h"
#import "NSString+BKPageControlView.h"
#import "BKPageControlMenuModel.h"

NSString * const kBKPageControlMenuID = @"kBKPageControlMenuID";
const float kSelectViewAnimateTimeInterval = 0.25;

@interface BKPageControlMenuView()<UIScrollViewDelegate>

/**
 保存的选中字体字号
 */
@property (nonatomic,assign) CGFloat tempMenuSelectTitleFontSize;
/**
 menu属性
 */
@property (nonatomic,strong) BKPageControlMenuModel * menuModel;
/**
 选中menu底部的线
 */
@property (nonatomic,strong) UIView * selectView;

@end

@implementation BKPageControlMenuView
@synthesize isTapMenuSwitchingIndex = _isTapMenuSwitchingIndex;

#pragma mark - 展示的vc数组

-(void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self reloadContentView];
}

#pragma mark - 选中的索引

-(void)setSelectIndex:(NSUInteger)selectIndex
{
    if (selectIndex > [self.titles count] - 1) {
        _selectIndex = [self.titles count] - 1;
    }else {
        _selectIndex = selectIndex;
    }
   
    if (![UIApplication sharedApplication].keyWindow.userInteractionEnabled) {
        return;
    }
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    
    _isTapMenuSwitchingIndex = YES;
    if ([self.delegate respondsToSelector:@selector(tapMenuSwitchSelectIndex:)]) {
        [self.delegate tapMenuSwitchSelectIndex:_selectIndex];
    }
    
    [self reloadContentView];
    
    [UIView animateWithDuration:kSelectViewAnimateTimeInterval animations:^{
        
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        self->_isTapMenuSwitchingIndex = NO;
    }];
}

#pragma mark - 导航视图

-(void)setLrInset:(CGFloat)lrInset
{
    _lrInset = lrInset;
    [self reloadContentView];
}

#pragma mark - 菜单设置

-(void)setMenuEqualDivisionW:(CGFloat)menuEqualDivisionW
{
    _menuEqualDivisionW = menuEqualDivisionW;
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
        self.selectView.hidden = NO;
    }else {
        self.selectView.hidden = YES;
    }
    
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
        [self reloadContentView];
    }
}

#pragma mark - 大小设置

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
    self.bottomLine.bk_y = self.bk_height - self.bottomLine.bk_height;
    self.selectView.bk_y = self.contentView.bk_height - self.selectView.bk_height;
    
    if ([self.delegate respondsToSelector:@selector(changeMenuViewFrame)]) {
        [self.delegate changeMenuViewFrame];
    }
    
    [self reloadContentView];
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
    self.selectViewStyle = BKPageControlMenuSelectViewStyleFollowMenuTitleWidth;
    self.selectViewConstantW = 15;
    self.selectViewHeight = 2;
    self.selectViewBottomMargin = 0;
    self.selectViewBackgroundColor = [UIColor blackColor];
    
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
}

-(void)initUI
{
    [self addSubview:self.contentView];
    [self addSubview:self.bottomLine];
    [self.contentView addSubview:self.selectView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.bottomLine.frame = CGRectMake(0, self.bk_height - BK_ONE_PIXEL, self.bk_width, BK_ONE_PIXEL);
    self.selectView.frame = CGRectMake(self.selectView.bk_x, self.contentView.bk_height - self.selectViewHeight - self.selectViewBottomMargin, self.selectView.bk_width, self.selectViewHeight);
}

#pragma mark - 导航内容视图

-(UIScrollView*)contentView
{
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.delegate = self;
        _contentView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _contentView;
}

/**
 刷新contentView
 */
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
        if (self.selectIndex == i) {
            font = [self getMenuFontSize:self.menuSelectTitleFontSize];
            color = self.menuSelectTitleColor;
        }else {
            font = [self getMenuFontSize:self.menuNormalTitleFontSize];
            color = self.menuNormalTitleColor;
        }
        CGFloat width = [title calculateSizeWithUIHeight:self.contentView.bk_height font:font].width;
        
        BKPageControlMenuPropertyModel * model = [[BKPageControlMenuPropertyModel alloc] init];
        model.color = color;
        model.font = font;
        model.titleWidth = width;
        if (self.menuEqualDivisionW == 0) {
            CGFloat x = (i == 0 ? self.lrInset : CGRectGetMaxX(lastRect)) + self.menuSpace;
            model.rect = CGRectMake(x, 0, width, self.contentView.bk_height);
        }else {
            CGFloat x = i == 0 ? self.lrInset : CGRectGetMaxX(lastRect);
            model.rect = CGRectMake(x, 0, self.menuEqualDivisionW, self.contentView.bk_height);
        }
        [self.menuModel.total addObject:model];
    
        lastRect = model.rect;
    }
    self.contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastRect) + self.lrInset + (self.menuEqualDivisionW == 0 ? self.menuSpace : 0), self.contentView.bk_height);
    
    CGFloat maxOffsetX = self.contentView.contentSize.width - self.contentView.bk_width;
    if (maxOffsetX > 0 && self.contentView.contentOffset.x > maxOffsetX) {
        self.contentView.contentOffset = CGPointMake(maxOffsetX, self.contentView.contentOffset.y);
    }
    
    [self displayMenu];
    [self adjustSelectViewPosition];
}

#pragma mark - 导航内容视图中标题

-(BKPageControlMenuModel*)menuModel
{
    if (!_menuModel) {
        _menuModel = [[BKPageControlMenuModel alloc] init];
    }
    return _menuModel;
}

/**
 创建menu
 
 @param identifier 标识符
 @return menu
 */
-(BKPageControlMenu*)createMenuWithReuseIdentifier:(NSString*)identifier
{
    BKPageControlMenu * menu = [[BKPageControlMenu alloc] initWithIdentifer:identifier];
    menu.textColor = self.menuNormalTitleColor;
    menu.font = [self getMenuFontSize:self.menuNormalTitleFontSize];
    menu.numberOfLines = self.menuNumberOfLines;
    menu.lineSpacing = self.menuLineSpacing;
    menu.contentInset = self.menuContentInset;
    menu.textAlignment = NSTextAlignmentCenter;
    menu.userInteractionEnabled = YES;
    __weak typeof(self) weakSelf = self;
    [menu setClickSelfCallBack:^(BKPageControlMenu * _Nonnull menu) {
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        if (weakSelf.selectIndex == menu.displayIndex) {
            return;
        }
        weakSelf.selectIndex = menu.displayIndex;
    }];
    return menu;
}

/**
 复用menu
 
 @param identifier 标识符
 @return menu
 */
-(BKPageControlMenu * _Nullable)dequeueReusableMenuWithReuseIdentifier:(NSString*)identifier forIndex:(NSUInteger)index
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
            menu = [self createMenuWithReuseIdentifier:identifier];
        }else {//有则复用
            menu = [self.menuModel.cache firstObject];
        }
    }
    return menu;
}

/**
 给menu赋值数据

 @param menu 标题
 @param index 索引
 */
-(void)assignDataForMenu:(BKPageControlMenu*)menu index:(NSInteger)index
{
    BKPageControlMenuPropertyModel * model = self.menuModel.total[index];
    
    menu.displayIndex = index;
    menu.frame = model.rect;
    menu.text = self.titles[index];
    menu.textColor = model.color;
    menu.font = model.font;
    menu.numberOfLines = self.menuNumberOfLines;
    menu.lineSpacing = self.menuLineSpacing;
    menu.contentInset = self.menuContentInset;
    
    if ([self.delegate respondsToSelector:@selector(menu:settingIconImageView:selectIconImageView:atIndex:)]) {
        [self.delegate menu:menu settingIconImageView:menu.iconImageView selectIconImageView:menu.sIconImageView atIndex:index];
    }
}

#pragma mark - menu标题font

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

/**
 显示可见的menu
 */
-(void)displayMenu
{
    //显示区域
    CGRect displayRect = CGRectMake(self.contentView.contentOffset.x, 0, self.contentView.bk_width, self.contentView.bk_height);
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
            BKPageControlMenu * menu = [self dequeueReusableMenuWithReuseIdentifier:kBKPageControlMenuID forIndex:idx];
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

#pragma mark - 底部分割线

-(UIImageView*)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bk_height - BK_ONE_PIXEL, self.bk_width, BK_ONE_PIXEL)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1];
    }
    return _bottomLine;
}

#pragma mark - 选中导航的线

-(void)setSelectViewStyle:(BKPageControlMenuSelectViewStyle)selectViewStyle
{
    _selectViewStyle = selectViewStyle;
    if (_selectView) {
        [self adjustSelectViewPosition];
    }
}

-(void)setSelectViewConstantW:(CGFloat)selectViewConstantW
{
    _selectViewConstantW = selectViewConstantW;
    if (_selectView) {
        [self adjustSelectViewPosition];
    }
}

-(void)setSelectViewHeight:(CGFloat)selectViewHeight
{
    _selectViewHeight = selectViewHeight;
    if (_selectView) {
        _selectView.bk_height = _selectViewHeight;
        _selectView.layer.cornerRadius = _selectView.bk_height/2.0f;
    }
}

-(void)setSelectViewBottomMargin:(CGFloat)selectViewBottomMargin
{
    _selectViewBottomMargin = selectViewBottomMargin;
    if (_selectView) {
        _selectView.bk_y = self.bk_height - _selectView.bk_height - _selectViewBottomMargin;
    }
}

-(void)setSelectViewBackgroundColor:(UIColor *)selectViewBackgroundColor
{
    _selectViewBackgroundColor = selectViewBackgroundColor;
    if (_selectView) {
        _selectView.backgroundColor = _selectViewBackgroundColor;
    }
}

-(UIView*)selectView
{
    if (!_selectView) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.bk_height - self.selectViewHeight - self.selectViewBottomMargin, 0, self.selectViewHeight)];
        _selectView.hidden = YES;
        _selectView.backgroundColor = self.selectViewBackgroundColor;
        _selectView.layer.cornerRadius = _selectView.bk_height/2.0f;
        _selectView.clipsToBounds = YES;
    }
    return _selectView;
}

-(void)adjustSelectViewPosition
{
    [self.menuModel.visible enumerateObjectsUsingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.displayIndex == self.selectIndex) {
            [UIView animateWithDuration:kSelectViewAnimateTimeInterval animations:^{
                BKPageControlMenuPropertyModel * model = self.menuModel.total[obj.displayIndex];
                if (self.selectViewStyle == BKPageControlMenuSelectViewStyleFollowMenuTitleWidth) {
                    self.selectView.bk_width = model.titleWidth;
                }else {
                    self.selectView.bk_width = self.selectViewConstantW;
                }
                self.selectView.bk_centerX = obj.bk_centerX;
                //修改了selectView的位置后 修改menuView的偏移量
                [self calcScrollContentOffsetAccordingToSelectViewPosition];
            }];
        }
    }];
}

#pragma mark - 滑动sliderView的方法

-(void)scrollCollectionView:(UICollectionView*)collectionView
{
    CGFloat offsetX = collectionView.contentOffset.x;
    NSInteger item = offsetX / collectionView.bk_width;
    //一页滑动的百分比
    CGFloat page_offsetX = (CGFloat)((NSInteger)offsetX % (NSInteger)collectionView.bk_width);
    CGFloat percentage = page_offsetX / collectionView.bk_width;
    //往左滑
    NSInteger fromIndex = item;
    NSInteger toIndex;
    if (collectionView.contentOffset.x < 0) {//偏移量<0肯定是往右滑
        toIndex = -1;
    }else {
        toIndex = item + 1;
    }
    //往右滑
    if (self.selectIndex == toIndex) {
        percentage = 1 - percentage;
        NSInteger tempIndex = fromIndex;
        fromIndex = toIndex;
        toIndex = tempIndex;
    }
    
    [self changeSelectPropertyWithFromIndex:fromIndex toIndex:toIndex percentage:percentage normalFontSize:self.menuNormalTitleFontSize selectFontSize:self.menuSelectTitleFontSize normalColor:self.menuNormalTitleColor selectColor:self.menuSelectTitleColor];
    [self calcScrollContentOffsetAccordingToSelectViewPosition];
    
    if ([self.delegate respondsToSelector:@selector(switchingSelectIndex:leavingIndex:percentage:)]) {
        [self.delegate switchingSelectIndex:toIndex leavingIndex:fromIndex percentage:percentage];
    }
}

#pragma mark - 滑动改变属性

/**
 滑动改变 字体颜色、大小、选中线位置

 @param fromIndex 来自index
 @param toIndex 至index
 @param percentage 当前页滑动百分比
 @param normalFontSize 默认字号
 @param selectFontSize 选中字号
 @param normalColor 默认颜色
 @param selectColor 选中颜色
 */
-(void)changeSelectPropertyWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex percentage:(CGFloat)percentage normalFontSize:(CGFloat)normalFontSize selectFontSize:(CGFloat)selectFontSize normalColor:(UIColor*)normalColor selectColor:(UIColor*)selectColor
{
    //数组越界return 或者 isnan(percentage)
    if (toIndex < 0 || toIndex > [self.menuModel.total count] - 1 || isnan(percentage)) {
        return;
    }
    
    //颜色
    CGFloat fromTitleR = [[selectColor valueForKey:@"redComponent"] floatValue];
    CGFloat fromTitleG = [[selectColor valueForKey:@"greenComponent"] floatValue];
    CGFloat fromTitleB = [[selectColor valueForKey:@"blueComponent"] floatValue];
    CGFloat fromTitleAlpha = [[selectColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat toTitleR = [[normalColor valueForKey:@"redComponent"] floatValue];
    CGFloat toTitleG = [[normalColor valueForKey:@"greenComponent"] floatValue];
    CGFloat toTitleB = [[normalColor valueForKey:@"blueComponent"] floatValue];
    CGFloat toTitleAlpha = [[normalColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat RChange = percentage * (fromTitleR - toTitleR);
    CGFloat GChange = percentage * (fromTitleG - toTitleG);
    CGFloat BChange = percentage * (fromTitleB - toTitleB);
    CGFloat alphaChange = percentage * (fromTitleAlpha - toTitleAlpha);
    
    UIColor * fromColor = [UIColor colorWithRed:fromTitleR-RChange green:fromTitleG-GChange blue:fromTitleB-BChange alpha:fromTitleAlpha-alphaChange];
    UIColor * toColor = [UIColor colorWithRed:toTitleR+RChange green:toTitleG+GChange blue:toTitleB+BChange alpha:toTitleAlpha+alphaChange];
    
    //字号
    CGFloat fontSizeChange = (selectFontSize - normalFontSize) * percentage;
    UIFont * fromFont = [self getMenuFontSize:selectFontSize - fontSizeChange];
    UIFont * toFont = [self getMenuFontSize:normalFontSize + fontSizeChange];
    
    BKPageControlMenuPropertyModel * fromModel = self.menuModel.total[fromIndex];
    fromModel.color = fromColor;
    fromModel.font = fromFont;
    [self.menuModel.total replaceObjectAtIndex:fromIndex withObject:fromModel];
    
    BKPageControlMenuPropertyModel * toModel = self.menuModel.total[toIndex];
    toModel.color = toColor;
    toModel.font = toFont;
    [self.menuModel.total replaceObjectAtIndex:toIndex withObject:toModel];
    
    CGRect lastRect = CGRectZero;
    for (int i = 0; i < [self.titles count]; i++) {
        NSString * title = self.titles[i];
        BKPageControlMenuPropertyModel * model = self.menuModel.total[i];
        //大小
        CGFloat width = [title calculateSizeWithUIHeight:self.contentView.bk_height font:model.font].width;
        model.titleWidth = width;
        if (self.menuEqualDivisionW == 0) {
            CGFloat x = (i == 0 ? self.lrInset : CGRectGetMaxX(lastRect)) + self.menuSpace;
            model.rect = CGRectMake(x, 0, width, self.contentView.bk_height);
        }else {
            CGFloat x = i == 0 ? self.lrInset : CGRectGetMaxX(lastRect);
            model.rect = CGRectMake(x, 0, self.menuEqualDivisionW, self.contentView.bk_height);
        }
        [self.menuModel.total replaceObjectAtIndex:i withObject:model];
        
        lastRect = model.rect;
    }
    self.contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastRect) + self.lrInset + (self.menuEqualDivisionW == 0 ? self.menuSpace : 0), self.contentView.bk_height);
    //赋值
    [self.menuModel.visible enumerateObjectsUsingBlock:^(BKPageControlMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKPageControlMenuPropertyModel * model = self.menuModel.total[obj.displayIndex];
        obj.frame = model.rect;
        obj.font = model.font;
        obj.textColor = model.color;
    }];
    
    //修改menu属性后新的model 用于修改选中线的位置
    BKPageControlMenuPropertyModel * new_fromModel = self.menuModel.total[fromIndex];
    BKPageControlMenuPropertyModel * new_toModel = self.menuModel.total[toIndex];
    
    CGFloat fromCenterX = CGRectGetMidX(new_fromModel.rect);
    CGFloat fromWidth = new_fromModel.titleWidth;
    CGFloat toCenterX = CGRectGetMidX(new_toModel.rect);
    CGFloat toWidth = new_toModel.titleWidth;
    
    if (self.selectViewStyle == BKPageControlMenuSelectViewStyleFollowMenuTitleWidth) {
        self.selectView.bk_width = (toWidth - fromWidth) * percentage + fromWidth;
    }else {
        self.selectView.bk_width = self.selectViewConstantW;
    }
    self.selectView.bk_centerX = fromCenterX + (toCenterX - fromCenterX) * percentage;
}

#pragma mark - 根据选中线的位置计算滑动偏移量

/**
 根据选中线的位置计算滑动偏移量(中心)
 */
-(void)calcScrollContentOffsetAccordingToSelectViewPosition
{
    //不能滚动return
    if (self.contentView.contentSize.width <= self.contentView.bk_width) {
        return;
    }
    
    CGFloat selectViewPositionGaps = CGRectGetMaxX(self.selectView.frame) - self.contentView.contentOffset.x;
    CGFloat left_right_Gap = (self.contentView.bk_width - self.selectView.bk_width)/2.0f;
    if (selectViewPositionGaps > self.contentView.bk_width - left_right_Gap) {
        CGFloat move = self.selectView.bk_x - left_right_Gap;
        if (move > self.contentView.contentSize.width - self.contentView.bk_width) {
            move = self.contentView.contentSize.width - self.contentView.bk_width;
        }
        [self.contentView setContentOffset:CGPointMake(move, 0) animated:NO];
    }else if (self.selectView.bk_x - self.contentView.contentOffset.x < left_right_Gap) {
        CGFloat move = self.selectView.bk_x - left_right_Gap;
        if (move < 0) {
            move = 0;
        }
        [self.contentView setContentOffset:CGPointMake(move, 0) animated:NO];
    }
}

#pragma mark - 获取可见的menu

-(NSArray<BKPageControlMenu*> *)getVisibleMenu
{
    return [self.menuModel.visible copy];
}

#pragma mark - 获取全部的menu属性

-(NSArray<BKPageControlMenuPropertyModel*> *)getTotalMenuProperty
{
    return [self.menuModel.total copy];
}

@end
