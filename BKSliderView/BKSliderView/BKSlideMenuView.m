//
//  BKSlideMenuView.m
//  BKSliderView
//
//  Created by zhaolin on 2018/11/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#import "BKSlideMenuView.h"
#import "BKSlideMenuModel.h"
#import "UIView+BKSlideView.h"
#import "NSString+BKSlideView.h"

NSString * const kSlideMenuID = @"kSlideMenuID";
const float kSelectViewAnimateTimeInterval = 0.25;

@interface BKSlideMenuView()<UIScrollViewDelegate>

@property (nonatomic,strong) BKSlideMenuModel * menuModel;

@end

@implementation BKSlideMenuView

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
    
    if (self.switchSelectIndexCallBack) {
        self.switchSelectIndexCallBack(self.selectIndex);
    }
    [self reloadContentView];
    
    [UIView animateWithDuration:kSelectViewAnimateTimeInterval animations:^{
        
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        if (self.switchSelectIndexCompleteCallBack) {
            self.switchSelectIndexCompleteCallBack();
        }
    }];
}

#pragma mark - 导航视图设置

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

-(void)setMenuSelectStyle:(BKSlideMenuSelectStyle)menuSelectStyle
{
    _menuSelectStyle = menuSelectStyle;
    
    if (_menuSelectStyle & BKSlideMenuSelectStyleChangeColor) {
        
    }else {
        self.selectMenuTitleColor = self.normalMenuTitleColor;
    }
    
    if (_menuSelectStyle & BKSlideMenuSelectStyleChangeFont) {
        
    }else {
        self.selectMenuTitleFontSize = self.normalMenuTitleFontSize;
    }
    
    if (_menuSelectStyle & BKSlideMenuSelectStyleDisplayLine) {
        self.selectView.hidden = NO;
    }else {
        self.selectView.hidden = YES;
    }
    
    [self reloadContentView];
}

-(void)setNormalMenuTitleFontSize:(CGFloat)normalMenuTitleFontSize
{
    _normalMenuTitleFontSize = normalMenuTitleFontSize;
    [self reloadContentView];
}

-(void)setSelectMenuTitleFontSize:(CGFloat)selectMenuTitleFontSize
{
    if (_menuSelectStyle & BKSlideMenuSelectStyleChangeFont) {
        _selectMenuTitleFontSize = selectMenuTitleFontSize;
        [self reloadContentView];
    }
}

-(void)setNormalMenuTitleColor:(UIColor *)normalMenuTitleColor
{
    _normalMenuTitleColor = normalMenuTitleColor;
    if (self.menuSelectStyle & BKSlideMenuSelectStyleChangeColor) {
        
    }else {
        _selectMenuTitleColor = _normalMenuTitleColor;
    }
    [self reloadContentView];
}

-(void)setSelectMenuTitleColor:(UIColor *)selectMenuTitleColor
{
    if (self.menuSelectStyle & BKSlideMenuSelectStyleChangeColor) {
        _selectMenuTitleColor = selectMenuTitleColor;
        [self reloadContentView];
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
    self.bottomLine.bk_y = self.bk_height - self.bottomLine.bk_height;
    self.selectView.bk_y = self.contentView.bk_height - self.selectView.bk_height;
    
    if (self.changeMenuViewFrameCallBack) {
        self.changeMenuViewFrameCallBack();
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
    self.menuSpace = 30;
    self.menuNumberOfLines = 1;
    self.menuSelectStyle = BKSlideMenuSelectStyleDisplayLine | BKSlideMenuSelectStyleChangeColor | BKSlideMenuSelectStyleChangeFont;
    self.normalMenuTitleFontSize = 14;
    self.selectMenuTitleFontSize = 17;
    self.normalMenuTitleColor = [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6];
    self.selectMenuTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

-(void)initUI
{
    [self addSubview:self.contentView];
    [self addSubview:self.bottomLine];
    [self.contentView addSubview:self.selectView];
}

#pragma mark - 导航内容视图

-(UIScrollView*)contentView
{
    if (!_contentView) {
        _contentView = [[UIScrollView alloc]initWithFrame:self.bounds];
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
    [visible enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKSlideMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.menuModel.visible removeObject:obj];
        [self.menuModel.cache addObject:obj];
    }];
    
    CGRect lastRect = CGRectZero;
    for (int i = 0; i < [self.titles count]; i++) {
        NSString * title = self.titles[i];
        UIFont * font = nil;
        UIColor * color = nil;
        if (self.selectIndex == i) {
            font = [UIFont systemFontOfSize:self.selectMenuTitleFontSize];
            color = self.selectMenuTitleColor;
        }else {
            font = [UIFont systemFontOfSize:self.normalMenuTitleFontSize];
            color = self.normalMenuTitleColor;
        }
        CGFloat width = [title calculateSizeWithUIHeight:self.contentView.bk_height font:font].width;
        
        BKSlideTotalMenuPropertyModel * model = [[BKSlideTotalMenuPropertyModel alloc] init];
        model.color = color;
        model.font = font;
        model.rect = CGRectMake(CGRectGetMaxX(lastRect) + self.menuSpace, 0, width, self.contentView.bk_height);
        [self.menuModel.total addObject:model];
    
        lastRect = model.rect;
    }
    self.contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastRect) + self.menuSpace, self.contentView.bk_height);
    
    CGFloat maxOffsetX = self.contentView.contentSize.width - self.contentView.bk_width;
    if (self.contentView.contentOffset.x > maxOffsetX) {
        self.contentView.contentOffset = CGPointMake(maxOffsetX, self.contentView.contentOffset.y);
    }
    
    [self displayMenu];
    [self adjustSelectViewPosition];
}

#pragma mark - 导航内容视图中标题

-(BKSlideMenuModel*)menuModel
{
    if (!_menuModel) {
        _menuModel = [[BKSlideMenuModel alloc] init];
    }
    return _menuModel;
}

/**
 获取对应index的menu

 @param index 索引
 @return menu
 */
-(BKSlideMenu*)getMenuForItemAtIndex:(NSInteger)index
{
    BKSlideMenu * menu = nil;
    for (BKSlideMenu * m in self.menuModel.visible) {
        if (m.displayIndex == index) {
            menu = m;
        }
    }
    //如果menu已经显示 则返回显示的menu 如果没有显示创建menu
    if (!menu) {
        //查看有没有能复用的menu
        menu = [self dequeueReusableMenuWithIdentifier:kSlideMenuID];
        if (!menu) {//没有则创建
            menu = [self createMenuWithIdentifer:kSlideMenuID];
        }
    }
    return menu;
}

/**
 给menu赋值数据

 @param menu 标题
 @param index 索引
 */
-(void)assignDataForMenu:(BKSlideMenu*)menu index:(NSInteger)index
{
    BKSlideTotalMenuPropertyModel * model = self.menuModel.total[index];
    
    menu.displayIndex = index;
    menu.frame = model.rect;
    menu.numberOfLines = self.menuNumberOfLines;
    menu.text = self.titles[index];
    menu.textColor = model.color;
    menu.font = model.font;
}

/**
 从缓存里取复用menu
 
 @param identifier 标识符
 @return menu
 */
-(BKSlideMenu * _Nullable)dequeueReusableMenuWithIdentifier:(NSString*)identifier
{
    if ([self.menuModel.cache count] == 0) {
        return nil;
    }
    BKSlideMenu * menu = [self.menuModel.cache firstObject];
    return menu;
}

/**
 创建menu
 
 @param identifier 标识符
 @return menu
 */
-(BKSlideMenu*)createMenuWithIdentifer:(NSString*)identifier
{
    BKSlideMenu * menu = [[BKSlideMenu alloc] initWithIdentifer:identifier];
    menu.textColor = self.normalMenuTitleColor;
    menu.font = [UIFont systemFontOfSize:self.normalMenuTitleFontSize];
    menu.numberOfLines = self.menuNumberOfLines;
    menu.textAlignment = NSTextAlignmentCenter;
    menu.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTap:)];
    [menu addGestureRecognizer:menuTap];
    return menu;
}

#pragma mark - 点击标题

-(void)menuTap:(UITapGestureRecognizer*)recognizer
{
    BKSlideMenu * menu = (BKSlideMenu*)recognizer.view;
    if (self.selectIndex == menu.displayIndex) {
        return;
    }
    self.selectIndex = menu.displayIndex;
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
    [visible enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKSlideMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!CGRectIntersectsRect(obj.frame, displayRect)) {
            [obj removeFromSuperview];
            [self.menuModel.visibleIndexs removeObject:@(obj.displayIndex)];
            [self.menuModel.visible removeObject:obj];
            [self.menuModel.cache addObject:obj];
        }
    }];
    //滑入显示区域 添加
    [self.menuModel.total enumerateObjectsUsingBlock:^(BKSlideTotalMenuPropertyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.rect, displayRect) && ![self.menuModel.visibleIndexs containsObject:@(idx)]) {
            BKSlideMenu * menu = [self getMenuForItemAtIndex:idx];
            [self assignDataForMenu:menu index:idx];
            [self.contentView addSubview:menu];
            [self.menuModel.visibleIndexs addObject:@(idx)];
            [self.menuModel.visible addObject:menu];
            [self.menuModel.cache removeObject:menu];
        }
    }];
    //防止快速滑动远距离menu执行removeFromSuperview没有删除掉 移除缓存所有显示menu
    [self.menuModel.cache enumerateObjectsUsingBlock:^(BKSlideMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

-(UIView*)selectView
{
    if (!_selectView) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.bk_height - 2, 0, 2)];
        _selectView.hidden = YES;
        _selectView.backgroundColor = [UIColor blackColor];
        _selectView.layer.cornerRadius = _selectView.bk_height/2.0f;
        _selectView.clipsToBounds = YES;
    }
    return _selectView;
}

-(void)adjustSelectViewPosition
{
    [self.menuModel.visible enumerateObjectsUsingBlock:^(BKSlideMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.displayIndex == self.selectIndex) {
            [UIView animateWithDuration:kSelectViewAnimateTimeInterval animations:^{
                self.selectView.bk_x = obj.bk_x;
                self.selectView.bk_width = obj.bk_width;
                //修改了selectView的位置后 修改menuView的偏移量
                [self calcScrollContentOffsetAccordingToSelectViewPosition];
            }];
        }
    }];
}

#pragma mark - 滑动slideView的方法

-(void)scrollCollectionView:(UICollectionView*)collectionView
{
    CGFloat offsetX = collectionView.contentOffset.x;
    NSInteger item = offsetX / collectionView.bk_width;
    //一页滑动的百分比
    CGFloat page_offsetX = (CGFloat)((NSInteger)offsetX % (NSInteger)collectionView.bk_width);
    //往左滑
    CGFloat scale = page_offsetX / collectionView.bk_width;
    NSInteger fromIndex = item;
    NSInteger toIndex;
    if (collectionView.contentOffset.x < 0) {//偏移量<0肯定是往右滑
        toIndex = -1;
    }else {
        toIndex = item + 1;
    }
    //往右滑
    if (self.selectIndex == toIndex) {
        scale = 1 - scale;
        NSInteger tempIndex = fromIndex;
        fromIndex = toIndex;
        toIndex = tempIndex;
    }
    
    [self changeSelectPropertyWithFromIndex:fromIndex toIndex:toIndex scale:scale];
    [self calcScrollContentOffsetAccordingToSelectViewPosition];
}

#pragma mark - 滑动改变属性

/**
 滑动改变 字体颜色、大小、选中线位置

 @param fromIndex 来自index
 @param toIndex 至index
 @param scale 当前页滑动百分比
 */
-(void)changeSelectPropertyWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex scale:(CGFloat)scale
{
    //数组越界return
    if (toIndex < 0 || toIndex > [self.menuModel.total count] - 1) {
        return;
    }
    
    //颜色
    CGFloat fromTitleR = [[_selectMenuTitleColor valueForKey:@"redComponent"] floatValue];
    CGFloat fromTitleG = [[_selectMenuTitleColor valueForKey:@"greenComponent"] floatValue];
    CGFloat fromTitleB = [[_selectMenuTitleColor valueForKey:@"blueComponent"] floatValue];
    CGFloat fromTitleAlpha = [[_selectMenuTitleColor valueForKey:@"alphaComponent"] floatValue];

    CGFloat toTitleR = [[_normalMenuTitleColor valueForKey:@"redComponent"] floatValue];
    CGFloat toTitleG = [[_normalMenuTitleColor valueForKey:@"greenComponent"] floatValue];
    CGFloat toTitleB = [[_normalMenuTitleColor valueForKey:@"blueComponent"] floatValue];
    CGFloat toTitleAlpha = [[_normalMenuTitleColor valueForKey:@"alphaComponent"] floatValue];

    CGFloat RChange = scale * (fromTitleR - toTitleR);
    CGFloat GChange = scale * (fromTitleG - toTitleG);
    CGFloat BChange = scale * (fromTitleB - toTitleB);
    CGFloat alphaChange = scale * (fromTitleAlpha - toTitleAlpha);

    UIColor * fromColor = [UIColor colorWithRed:fromTitleR-RChange green:fromTitleG-GChange blue:fromTitleB-BChange alpha:fromTitleAlpha-alphaChange];
    UIColor * toColor = [UIColor colorWithRed:toTitleR+RChange green:toTitleG+GChange blue:toTitleB+BChange alpha:toTitleAlpha+alphaChange];
    
    //字号
    CGFloat fontSizeChange = (self.selectMenuTitleFontSize - self.normalMenuTitleFontSize) * scale;
    UIFont * fromFont = [UIFont systemFontOfSize:self.selectMenuTitleFontSize - fontSizeChange];
    UIFont * toFont = [UIFont systemFontOfSize:self.normalMenuTitleFontSize + fontSizeChange];

    BKSlideTotalMenuPropertyModel * fromModel = self.menuModel.total[fromIndex];
    fromModel.color = fromColor;
    fromModel.font = fromFont;
    [self.menuModel.total replaceObjectAtIndex:fromIndex withObject:fromModel];

    BKSlideTotalMenuPropertyModel * toModel = self.menuModel.total[toIndex];
    toModel.color = toColor;
    toModel.font = toFont;
    [self.menuModel.total replaceObjectAtIndex:toIndex withObject:toModel];

    CGRect lastRect = CGRectZero;
    for (int i = 0; i < [self.titles count]; i++) {
        NSString * title = self.titles[i];
        BKSlideTotalMenuPropertyModel * model = self.menuModel.total[i];
        //大小
        CGFloat width = [title calculateSizeWithUIHeight:self.contentView.bk_height font:model.font].width;
        model.rect = CGRectMake(CGRectGetMaxX(lastRect) + self.menuSpace, 0, width, self.contentView.bk_height);
        [self.menuModel.total replaceObjectAtIndex:i withObject:model];

        lastRect = model.rect;
    }
    self.contentView.contentSize = CGSizeMake(CGRectGetMaxX(lastRect) + self.menuSpace, self.contentView.bk_height);
    //赋值
    [self.menuModel.visible enumerateObjectsUsingBlock:^(BKSlideMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKSlideTotalMenuPropertyModel * model = self.menuModel.total[obj.displayIndex];
        obj.frame = model.rect;
        obj.font = model.font;
        obj.textColor = model.color;
    }];
    
    //修改menu属性后新的model 用于修改选中线的位置
    BKSlideTotalMenuPropertyModel * new_fromModel = self.menuModel.total[fromIndex];
    BKSlideTotalMenuPropertyModel * new_toModel = self.menuModel.total[toIndex];
    
    CGFloat fromX = new_fromModel.rect.origin.x;
    CGFloat fromWidth = new_fromModel.rect.size.width;
    CGFloat toX = new_toModel.rect.origin.x;
    CGFloat toWidth = new_toModel.rect.size.width;
    
    self.selectView.bk_x = fromX + (toX - fromX) * scale;
    self.selectView.bk_width = (toWidth - fromWidth) * scale + fromWidth;
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

@end
