//
//  BKSlideView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKSlideView.h"

@interface BKSlideView()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    /**
     *  是否初始化完毕
     */
    BOOL isInitFinishFlag;
    
    /**
     *  间距
     */
    CGFloat menuTitleLength;
    
    /**
     *  选中的titleBtn
     */
    UIButton * selectTitleBtn;
    
    /**
     *  是否点击menuTitle翻页
     */
    BOOL isTapMenuTitleFlag;
    
    //    自定义selectView
    //    是否自定义selectView
    BOOL isCustomSelectView;
    
    
}
@end

@implementation BKSlideView

@synthesize slideView = _slideView;
@synthesize slideMenuView = _slideMenuView;
@synthesize menuTitleArray = _menuTitleArray;

#pragma mark - 刷新

-(void)reloadView
{
    if (isInitFinishFlag) {
        
        [[_slideMenuView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag != 0 && [obj isKindOfClass:[UIButton class]]) {
                [obj removeFromSuperview];
            }
        }];
        
        [self initAnyButton];
    }
}

#pragma mark - 字体

-(void)setNormalMenuTitleFont:(UIFont *)normalMenuTitleFont
{
    _normalMenuTitleFont = normalMenuTitleFont;
    [self reloadView];
}

-(void)setFontGap:(CGFloat)fontGap
{
    _fontGap = fontGap;
    [self reloadView];
}

#pragma mark - 颜色

-(void)setNormalMenuTitleColor:(UIColor *)normalMenuTitleColor
{
    _normalMenuTitleColor = normalMenuTitleColor;
    [self reloadView];
}

-(void)setSelectMenuTitleColor:(UIColor *)selectMenuTitleColor
{
    _selectMenuTitleColor = selectMenuTitleColor;
    [self reloadView];
}

#pragma mark - 改变选中

-(void)setSelectIndex:(NSInteger)selectIndex
{
    if (selectIndex > [_menuTitleArray count]) {
        return;
    }
    _selectIndex = selectIndex;
    [self reloadView];
}

#pragma mark - menuTitle 距离

-(void)setSlideMenuViewTitleWidthStyle:(BKSlideMenuViewTitleWidthStyle)slideMenuViewTitleWidthStyle
{
    _slideMenuViewTitleWidthStyle = slideMenuViewTitleWidthStyle;
    switch (_slideMenuViewTitleWidthStyle) {
        case SlideMenuViewTitleWidthStyleDefault:
        {
            menuTitleLength = TITLE_GAP;
        }
            break;
        case SlideMenuViewTitleWidthStyleSame:
        {
            menuTitleLength = MENU_TITLE_WIDTH;
        }
            break;
        default:
            break;
    }
    [self reloadView];
}

#pragma mark - 初始

-(instancetype)initWithFrame:(CGRect)frame menuTitleArray:(NSArray *)titleArray delegate:(id<BKSlideViewDelegate>)customDelegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _menuTitleArray = titleArray;
        _customDelegate = customDelegate;
        
        /**
         *  显示的SelectScrollView
         */
        [self initSlideMenuView];
        
        /**
         *  显示的View
         */
        [self initSlideView];
    }
    
    return self;
}

-(void)initSlideMenuView
{
    _slideMenuView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, SLIDE_MENU_VIEW_HEIGHT)];
    _slideMenuView.backgroundColor = [UIColor whiteColor];
    _slideMenuView.showsHorizontalScrollIndicator = NO;
    _slideMenuView.showsVerticalScrollIndicator = NO;
    [self addSubview:_slideMenuView];
    
    [self initData];
    [self initAnyButton];
    [self initSelectView];
    
    isInitFinishFlag = YES;
}

-(void)initData
{
    _selectIndex = 1;
    
    _normalMenuTitleFont = [UIFont systemFontOfSize:NORMAL_TITLE_FONT];
    _fontGap = FONT_GAP;
    
    _normalMenuTitleColor = NORMAL_TITLE_COLOR;
    _selectMenuTitleColor = SELECT_TITLE_COLOR;
    
    self.slideMenuViewTitleWidthStyle = SlideMenuViewTitleWidthStyleDefault;
    
    _slideMenuViewSelectStyle = SlideMenuViewSelectStyleHaveLine | SlideMenuViewSelectStyleChangeFont | SlideMenuViewSelectStyleChangeColor;
}

-(CGSize)sizeWithString:(NSString *)string UIHeight:(CGFloat)height font:(UIFont*)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
    
    return rect.size;
}

-(CGFloat)changeWidthView:(UILabel*)view
{
    CGSize viewSize = [self sizeWithString:view.text UIHeight:view.frame.size.height font:view.font];
    CGFloat width = viewSize.width;
    return width;
}

-(void)initAnyButton
{
    __block UIView * lastView;
    
    switch (_slideMenuViewTitleWidthStyle) {
        case SlideMenuViewTitleWidthStyleDefault:
        {
            [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                titleBtn.frame = CGRectMake((lastView?CGRectGetMaxX(lastView.frame)+menuTitleLength:menuTitleLength/2.0f), 0, 0, SLIDE_MENU_VIEW_HEIGHT);
                [titleBtn setBackgroundColor:[UIColor clearColor]];
                [titleBtn setTitle:obj forState:UIControlStateNormal];
                [titleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
                titleBtn.titleLabel.font = _normalMenuTitleFont;
                titleBtn.adjustsImageWhenHighlighted = NO;
                titleBtn.tag = idx + 1;
                
                CGRect titleRect = titleBtn.frame;
                titleRect.size.width = [self changeWidthView:titleBtn.titleLabel];
                titleBtn.frame = titleRect;
                
                [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                if (titleBtn.tag == _selectIndex) {
                    [self titleBtnClick:titleBtn];
                }
                [_slideMenuView addSubview:titleBtn];
                
                lastView = titleBtn;
            }];
            
            _slideMenuView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame)+menuTitleLength/2.0f, SLIDE_MENU_VIEW_HEIGHT);
        }
            break;
        case SlideMenuViewTitleWidthStyleSame:
        {
            [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                titleBtn.frame = CGRectMake((lastView?CGRectGetMaxX(lastView.frame):0), 0, menuTitleLength, SLIDE_MENU_VIEW_HEIGHT);
                [titleBtn setBackgroundColor:[UIColor clearColor]];
                [titleBtn setTitle:obj forState:UIControlStateNormal];
                [titleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
                titleBtn.titleLabel.font = _normalMenuTitleFont;
                titleBtn.adjustsImageWhenHighlighted = NO;
                titleBtn.tag = idx + 1;
                [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                if (titleBtn.tag == _selectIndex) {
                    [self titleBtnClick:titleBtn];
                }
                [_slideMenuView addSubview:titleBtn];
                
                lastView = titleBtn;
                
            }];
            
            _slideMenuView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), SLIDE_MENU_VIEW_HEIGHT);
        }
            break;
        default:
            break;
    }
}

-(void)initSelectView
{
    _selectView = [[UIView alloc]initWithFrame:CGRectMake(0,SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT,selectTitleBtn.frame.size.width + menuTitleLength,DEFAULT_SELECTVIEW_HEIGHT)];
    CGPoint selectViewCenter = _selectView.center;
    selectViewCenter.x = selectTitleBtn.center.x;
    _selectView.center = selectViewCenter;
    _selectView.backgroundColor = [UIColor blackColor];
    _selectView.layer.cornerRadius = _selectView.bounds.size.height/2.0f;
    _selectView.clipsToBounds = YES;
    [_slideMenuView addSubview:_selectView];
}

-(void)initSlideView
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height-SLIDE_MENU_VIEW_HEIGHT);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _slideView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SLIDE_MENU_VIEW_HEIGHT, self.frame.size.width, self.frame.size.height - SLIDE_MENU_VIEW_HEIGHT) collectionViewLayout:layout];
    _slideView.showsHorizontalScrollIndicator = NO;
    _slideView.showsVerticalScrollIndicator = NO;
    _slideView.delegate = self;
    _slideView.dataSource = self;
    _slideView.backgroundColor = [UIColor clearColor];
    _slideView.pagingEnabled = YES;
    [self addSubview:_slideView];
    
    [_slideView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"slideView"];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_menuTitleArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"slideView" forIndexPath:indexPath];
    
    [[cell subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    if ([_customDelegate respondsToSelector:@selector(initInView:atIndex:)]) {
        [_customDelegate initInView:cell atIndex:indexPath.item];
    }
    
    return cell;
}

#pragma mark - 自定义selectView

-(void)setSlideMenuViewSelectStyle:(BKSlideMenuViewSelectStyle)slideMenuViewSelectStyle
{
    _slideMenuViewSelectStyle = slideMenuViewSelectStyle;
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeFont) {
        
    }else{
        _fontGap = 1;
        [self reloadView];
    }
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        
    }else{
        _selectMenuTitleColor = _normalMenuTitleColor;
        [self reloadView];
    }
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleHaveLine) {
        
    }else{
        _selectView.frame = CGRectMake(0, 0, selectTitleBtn.frame.size.width, SLIDE_MENU_VIEW_HEIGHT);
        CGPoint selectViewCenter = _selectView.center;
        selectViewCenter.x = selectTitleBtn.center.x;
        _selectView.center = selectViewCenter;
        _selectView.backgroundColor = [UIColor clearColor];
        _selectView.layer.cornerRadius = 0;
        _selectView.clipsToBounds = NO;
        
        if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleCustom) {
            [self refreshChangeSelectView];
        }
    }
}

-(void)refreshChangeSelectView
{
    if ([self.customDelegate respondsToSelector:@selector(editChooseSelectView:)]) {
        [self.customDelegate editChooseSelectView:_selectView];
    }
    if ([self.customDelegate respondsToSelector:@selector(editSubInSelectView:)]) {
        [self.customDelegate editSubInSelectView:_selectView];
    }
    
    [_selectView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    isCustomSelectView = YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isEqual:_selectView]) {
        if ([self.customDelegate respondsToSelector:@selector(editSubInSelectView:)]) {
            [self.customDelegate editSubInSelectView:_selectView];
        }
    }
}

-(void)dealloc
{
    if (isCustomSelectView) {
        [_selectView removeObserver:self forKeyPath:@"frame"];
    }
}

#pragma mark - UIButton

-(void)titleBtnClick:(UIButton*)button
{
    if (isTapMenuTitleFlag || button == selectTitleBtn) {
        return;
    }
    isTapMenuTitleFlag = YES;
    
    if (_selectView) {
        CGRect selectViewRect = button.frame;
        CGPoint selectViewCenter = _selectView.center;
        switch (_slideMenuViewTitleWidthStyle) {
            case SlideMenuViewTitleWidthStyleDefault:
            {
                selectViewRect.size.width = button.frame.size.width * _fontGap + menuTitleLength;
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                
                selectViewCenter.x = button.center.x;
            }
                break;
            case SlideMenuViewTitleWidthStyleSame:
            {
                selectViewRect.size.width = button.frame.size.width * _fontGap;
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                
                selectViewCenter.x = button.center.x;
            }
                break;
            default:
                break;
        }
        
        if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleCustom) {
            selectViewRect.origin.y = 0;
            selectViewRect.size.height = SLIDE_MENU_VIEW_HEIGHT;
        }
        
        [selectTitleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        [button setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            _selectView.frame = selectViewRect;
            _selectView.center = selectViewCenter;
            
            selectTitleBtn.transform = CGAffineTransformMakeScale(1, 1);
            button.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
            
        } completion:^(BOOL finished) {
            
            selectTitleBtn = button;
            
            isTapMenuTitleFlag = NO;
            
        }];
    }else{
        selectTitleBtn.transform = CGAffineTransformMakeScale(1, 1);
        [selectTitleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        selectTitleBtn = button;
        [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
        selectTitleBtn.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
        
        isTapMenuTitleFlag = NO;
    }
    
    _selectIndex = button.tag;
    
    [self rollSlideViewToIndexView:_selectIndex];
}

/**
 *     移动 SlideView 至第 index 页
 */
-(void)rollSlideViewToIndexView:(NSInteger)index
{
    CGFloat rollLength = _slideView.frame.size.width * (index-1);
    [_slideView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

/**
 *  获取当前显示View
 */
-(UIView*)getDisplayView
{
    CGPoint pInView = [self convertPoint:_slideView.center toView:_slideView];
    NSIndexPath *indexPathNow = [_slideView indexPathForItemAtPoint:pInView];
    NSInteger item = indexPathNow.item;
    
    UICollectionViewCell * view = [_slideView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
    return view;
}

#pragma mark - UIScrollDelegate & 滑动动画

/**
 *  略微调整选中状态的显示
 *
 *  @param item 选中的item
 */
-(void)fineTuneAndSelectItem:(NSInteger)item
{
    [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag != 0 && [obj isKindOfClass:[UIButton class]]) {
            UIButton * button = (UIButton*)obj;
            
            if (item == button.tag) {
                selectTitleBtn = button;
                _selectIndex = item;
                
                [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
                selectTitleBtn.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
                
                CGRect selectViewRect = selectTitleBtn.frame;
                CGPoint selectViewCenter = _selectView.center;
                switch (_slideMenuViewTitleWidthStyle) {
                    case SlideMenuViewTitleWidthStyleDefault:
                    {
                        selectViewRect.size.width = selectTitleBtn.frame.size.width + menuTitleLength;
                        selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                        selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                        
                        selectViewCenter.x = selectTitleBtn.center.x;
                    }
                        break;
                    case SlideMenuViewTitleWidthStyleSame:
                    {
                        selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                        selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                        
                        selectViewCenter.x = selectTitleBtn.center.x;
                    }
                        break;
                    default:
                        break;
                }
                
                if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleCustom) {
                    selectViewRect.origin.y = 0;
                    selectViewRect.size.height = SLIDE_MENU_VIEW_HEIGHT;
                }
                
                _selectView.frame = selectViewRect;
                _selectView.center = selectViewCenter;
                
            }else{
                [button setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
                button.transform = CGAffineTransformMakeScale(1, 1);
            }
        }
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _slideView) {
        if (_slideMenuViewSelectStyle == SlideMenuViewSelectStyleNone || isTapMenuTitleFlag) {
            return;
        }
        
        CGFloat slideViewContentOffX = _slideView.contentOffset.x;
        
        // 第几页
        NSInteger item = slideViewContentOffX / _slideView.frame.size.width + 1;
        
        if (item < 1) {
            [self fineTuneAndSelectItem:1];
            return;
        }else if (item >= [_menuTitleArray count]) {
            [self fineTuneAndSelectItem:[_menuTitleArray count]];
            return;
        }
        
        // 这一页滑动了多少
        CGFloat page_contentOffX = (CGFloat)((NSInteger)slideViewContentOffX % (NSInteger)_slideView.frame.size.width);
        // 滑走的button
        UIButton * fromButton = (UIButton*)[self viewWithTag:item];
        // 滑向的button
        UIButton * toButton = (UIButton*)[self viewWithTag:item+1];
        // 这一页滑的百分比
        CGFloat scale = page_contentOffX / _slideView.frame.size.width;
        
        if (scale == 0) {
            [self fineTuneAndSelectItem:item];
            return;
        }
        
        if (scale < 0.5) {
            UIButton * button = (UIButton*)[self viewWithTag:item];
            selectTitleBtn = button;
            _selectIndex = item;
        }
        
        // 根据方向从新控制滑向的button 和 百分比
        CGFloat now_scale = 0.0;
        UIButton * now_frombutton;
        UIButton * now_toButton;
        if (selectTitleBtn == fromButton) {
            now_scale = scale;
            now_frombutton = fromButton;
            now_toButton = toButton;
        }else if (selectTitleBtn == toButton) {
            now_scale = 1-scale;
            now_frombutton = toButton;
            now_toButton = fromButton;
        }
        
        /**
         *  滑动中所做的动画
         */
        if (_slideMenuView.contentSize.width > self.frame.size.width) {
            //    动画格式 并且改变 self contentOffset.x距离
            [self moveChangeAnimation:self.slideMenuViewChangeStyle];
        }
        
        if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeFont) {
            //    改变滑动中 即将取消选择 和 选择的 cell 字号
            [self magnifyFontWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
        }
        
        //        改变selectView滑动位置
        [self selectViewChangeWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
        
        if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
            //    改变滑动中 即将取消选择 和 选择的 cell 字体颜色
            [self ChangeSelectColorWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _slideView) {
        if (_slideMenuViewSelectStyle == SlideMenuViewSelectStyleNone || isTapMenuTitleFlag) {
            return;
        }
        
        CGPoint pInView = [self convertPoint:_slideView.center toView:_slideView];
        NSIndexPath *indexPathNow = [_slideView indexPathForItemAtPoint:pInView];
        NSInteger item = indexPathNow.item;
        
        _selectIndex = item + 1;
        UIButton * selectBtn = (UIButton*)[self viewWithTag:_selectIndex];
        
        selectTitleBtn.transform = CGAffineTransformMakeScale(1, 1);
        [selectTitleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        selectTitleBtn = selectBtn;
        [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
        selectTitleBtn.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
        
        CGRect selectViewRect = selectBtn.frame;
        CGPoint selectViewCenter = _selectView.center;
        switch (_slideMenuViewTitleWidthStyle) {
            case SlideMenuViewTitleWidthStyleDefault:
            {
                selectViewRect.size.width = selectBtn.frame.size.width + menuTitleLength;
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                
                selectViewCenter.x = selectBtn.center.x;
            }
                break;
            case SlideMenuViewTitleWidthStyleSame:
            {
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                
                selectViewCenter.x = selectBtn.center.x;
            }
                break;
            default:
                break;
        }
        
        if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleCustom) {
            selectViewRect.origin.y = 0;
            selectViewRect.size.height = SLIDE_MENU_VIEW_HEIGHT;
        }
        
        _selectView.frame = selectViewRect;
        _selectView.center = selectViewCenter;
    }
}

/**
 *     设置 滑动 字号大小
 */
-(void)magnifyFontWithFromButton:(UIButton*)fromButton toButton:(UIButton*)toButton scale:(CGFloat)scale
{
    CGFloat gap = scale * (_fontGap-1);
    
    fromButton.transform = CGAffineTransformMakeScale(_fontGap-gap, _fontGap-gap);
    toButton.transform = CGAffineTransformMakeScale(1+gap, 1+gap);
}

/**
 *     selectView 改变滑动位置
 */
-(void)selectViewChangeWithFromButton:(UIButton*)fromButton toButton:(UIButton*)toButton scale:(CGFloat)scale
{
    CGRect selectViewRect = _selectView.frame;
    CGPoint selectViewCenter = _selectView.center;
    
    switch (_slideMenuViewTitleWidthStyle) {
        case SlideMenuViewTitleWidthStyleDefault:
        {
            selectViewRect.size.width = (toButton.frame.size.width - fromButton.frame.size.width) * scale + fromButton.frame.size.width + menuTitleLength;
            selectViewCenter.x = fromButton.center.x + (toButton.center.x - fromButton.center.x)*scale;
        }
            break;
        case SlideMenuViewTitleWidthStyleSame:
        {
            selectViewRect.size.width = (toButton.frame.size.width - fromButton.frame.size.width) * scale + fromButton.frame.size.width;
            selectViewCenter.x = fromButton.center.x + (toButton.center.x - fromButton.center.x)*scale;
        }
            break;
        default:
            break;
    }
    
    _selectView.frame = selectViewRect;
    _selectView.center = selectViewCenter;
}

/**
 *     设置 滑动 字体颜色 透明度
 */
-(void)ChangeSelectColorWithFromButton:(UIButton*)fromButton toButton:(UIButton*)toButton scale:(CGFloat)scale
{
    CGFloat fromTitleAlpha = [[_selectMenuTitleColor valueForKey:@"alphaComponent"] floatValue];
    CGFloat toTitleAlpha = [[_normalMenuTitleColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat fromTitleR = [[_selectMenuTitleColor valueForKey:@"redComponent"] floatValue];
    CGFloat toTitleR = [[_normalMenuTitleColor valueForKey:@"redComponent"] floatValue];
    
    CGFloat fromTitleG = [[_selectMenuTitleColor valueForKey:@"greenComponent"] floatValue];
    CGFloat toTitleG = [[_normalMenuTitleColor valueForKey:@"greenComponent"] floatValue];
    
    CGFloat fromTitleB = [[_selectMenuTitleColor valueForKey:@"blueComponent"] floatValue];
    CGFloat toTitleB = [[_normalMenuTitleColor valueForKey:@"blueComponent"] floatValue];
    
    CGFloat alphaGap = fromTitleAlpha - toTitleAlpha;
    CGFloat RGap = fromTitleR - toTitleR;
    CGFloat GGap = fromTitleG - toTitleG ;
    CGFloat BGap = fromTitleB - toTitleB ;
    
    CGFloat alphaChange = scale * alphaGap;
    CGFloat RChange = scale * RGap;
    CGFloat GChange = scale * GGap;
    CGFloat BChange = scale * BGap;
    
    UIColor * new_fromChangeColor = [UIColor colorWithRed:fromTitleR-RChange green:fromTitleG-GChange blue:fromTitleB-BChange alpha:fromTitleAlpha-alphaChange];
    UIColor * new_toChangeColor = [UIColor colorWithRed:toTitleR+RChange green:toTitleG+GChange blue:toTitleB+BChange alpha:toTitleAlpha+alphaChange];
    
    [fromButton setTitleColor:new_fromChangeColor forState:UIControlStateNormal];
    [toButton setTitleColor:new_toChangeColor forState:UIControlStateNormal];
}

#pragma mark - 动画格式

/**
 *     滑动动画选择
 */
-(void)moveChangeAnimation:(BKSlideMenuViewChangeStyle)style
{
    switch (style) {
        case SlideMenuViewChangeStyleDefault:
        {
            [self changeSelectViewDefaultAnimation];
        }
            break;
        case SlideMenuViewChangeStyleCenter:
        {
            [self changeSelectViewCenterAnimation];
        }
            break;
        default:
            break;
    }
}

/**
 *     scroll Default
 */
-(void)changeSelectViewDefaultAnimation
{
    CGFloat selectViewPositionGaps = CGRectGetMaxX(_selectView.frame) - _slideMenuView.contentOffset.x;
    if (selectViewPositionGaps > self.frame.size.width) {
        [_slideMenuView setContentOffset:CGPointMake(_slideMenuView.contentOffset.x + (selectViewPositionGaps - self.frame.size.width), 0) animated:NO];
        if (_slideMenuView.contentOffset.x > _slideMenuView.contentSize.width - self.frame.size.width) {
            [_slideMenuView setContentOffset:CGPointMake(_slideMenuView.contentSize.width - self.frame.size.width, 0) animated:NO];
        }
    }else if (_selectView.frame.origin.x - _slideMenuView.contentOffset.x < 0) {
        [_slideMenuView setContentOffset:CGPointMake(_selectView.frame.origin.x, 0) animated:NO];
        if (_slideMenuView.contentOffset.x < 0) {
            [_slideMenuView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }
}

/**
 *     scroll Center
 */
-(void)changeSelectViewCenterAnimation
{
    CGFloat selectViewPositionGaps = CGRectGetMaxX(_selectView.frame) - _slideMenuView.contentOffset.x;
    CGFloat left_right_Gap = (self.frame.size.width - _selectView.frame.size.width)/2.0f;
    if (selectViewPositionGaps > self.frame.size.width - left_right_Gap) {
        CGFloat move = _selectView.frame.origin.x - left_right_Gap;
        if (move > _slideMenuView.contentSize.width - self.frame.size.width) {
            move = _slideMenuView.contentSize.width - self.frame.size.width;
        }
        [_slideMenuView setContentOffset:CGPointMake(move, 0) animated:NO];
    }else if (_selectView.frame.origin.x - _slideMenuView.contentOffset.x < left_right_Gap) {
        CGFloat move = _selectView.frame.origin.x - left_right_Gap;
        if (move<0) {
            move = 0;
        }
        [_slideMenuView setContentOffset:CGPointMake(move, 0) animated:NO];
    }
}

@end
