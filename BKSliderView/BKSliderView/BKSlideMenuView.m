//
//  BKSlideMenuView.m
//
//  Created on 16/2/2
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define NORMAL_TITLE_FONT 14.0f
#define FONT_GAP 1.1

#define NORMAL_TITLE_COLOR [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6]
#define SELECT_TITLE_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

#define TITLE_GAP 20.0f
#define MENU_TITLE_WIDTH 100.0f

#define DEFAULT_SELECTVIEW_HEIGHT 2

#import "BKSlideMenuView.h"
#import "BKSlideView.h"

@interface BKSlideMenuView()<UIScrollViewDelegate>
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

@implementation BKSlideMenuView
@synthesize menuTitleArray = _menuTitleArray;

#pragma mark - 刷新

-(void)reloadView
{
    if (isInitFinishFlag) {
        
        [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    _selectIndex = selectIndex;
    [self reloadView];
}

#pragma mark - menuTitle 距离

-(void)setTitleWidthStyle:(BKSlideMenuViewTitleWidthStyle)titleWidthStyle
{
    _titleWidthStyle = titleWidthStyle;
    switch (titleWidthStyle) {
        case TitleWidthStyleDefault:
        {
            menuTitleLength = TITLE_GAP;
        }
            break;
        case TitleWidthStyleSame:
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

-(instancetype)initWithFrame:(CGRect)frame menuTitleArray:(NSArray*)titleArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _menuTitleArray = titleArray;
        
        [self initData];
        [self initSelfProperty];
        [self initAnyButton];
        
        if (!self.customDelegate) {
            [self initSelectView];
        }
        
        isInitFinishFlag = YES;
    }
    return self;
}

-(void)initData
{
    _selectIndex = 1;
    
    _normalMenuTitleFont = [UIFont systemFontOfSize:NORMAL_TITLE_FONT];
    _fontGap = FONT_GAP;
    
    _normalMenuTitleColor = NORMAL_TITLE_COLOR;
    _selectMenuTitleColor = SELECT_TITLE_COLOR;

    self.titleWidthStyle = TitleWidthStyleDefault;
    
    _selectStyle = SelectStyleHaveLine | SelectStyleChangeFont | SelectStyleChangeColor;
}

-(void)initSelfProperty
{
    self.backgroundColor = [UIColor whiteColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
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
    
    switch (_titleWidthStyle) {
        case TitleWidthStyleDefault:
        {
            [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                titleBtn.frame = CGRectMake((lastView?CGRectGetMaxX(lastView.frame)+menuTitleLength:menuTitleLength/2.0f), 0, 0, self.frame.size.height);
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
                [self addSubview:titleBtn];
                
                lastView = titleBtn;
            }];
            
            self.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame)+menuTitleLength/2.0f, self.frame.size.height);
        }
            break;
        case TitleWidthStyleSame:
        {
            [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                titleBtn.frame = CGRectMake((lastView?CGRectGetMaxX(lastView.frame):0), 0, menuTitleLength, self.frame.size.height);
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
                [self addSubview:titleBtn];
                
                lastView = titleBtn;
                
            }];
            
            self.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), self.frame.size.height);
        }
            break;
        default:
            break;
    }
}

-(void)initSelectView
{
    _selectView = [[UIView alloc]initWithFrame:CGRectMake(0,self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT,selectTitleBtn.frame.size.width + menuTitleLength,DEFAULT_SELECTVIEW_HEIGHT)];
    CGPoint selectViewCenter = _selectView.center;
    selectViewCenter.x = selectTitleBtn.center.x;
    _selectView.center = selectViewCenter;
    _selectView.backgroundColor = [UIColor blackColor];
    _selectView.layer.cornerRadius = _selectView.bounds.size.height/2.0f;
    _selectView.clipsToBounds = YES;
    [self addSubview:_selectView];
}

#pragma mark - 自定义selectView

-(void)setSelectStyle:(BKSlideMenuViewSelectStyle)selectStyle
{
    _selectStyle = selectStyle;
    
    if (_selectStyle & SelectStyleChangeFont) {
        
    }else{
        _fontGap = 1;
        [self reloadView];
    }
    
    if (_selectStyle & SelectStyleChangeColor) {
        
    }else{
        _selectMenuTitleColor = _normalMenuTitleColor;
        [self reloadView];
    }
    
    if (selectStyle & SelectStyleHaveLine) {
        
    }else{
        _selectView.frame = CGRectMake(0, 0, selectTitleBtn.frame.size.width, self.frame.size.height);
        CGPoint selectViewCenter = _selectView.center;
        selectViewCenter.x = selectTitleBtn.center.x;
        _selectView.center = selectViewCenter;
        _selectView.backgroundColor = [UIColor clearColor];
        _selectView.layer.cornerRadius = 0;
        _selectView.clipsToBounds = NO;
        
        if (selectStyle & SelectStyleCustom) {
            [self refreshChangeSelectView];
        }
    }
}

-(void)refreshChangeSelectView
{
    if ([self.customDelegate respondsToSelector:@selector(modifyChooseSelectView:)]) {
        [self.customDelegate modifyChooseSelectView:_selectView];
    }
    
    [_selectView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    isCustomSelectView = YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isEqual:_selectView]) {
        if ([self.customDelegate respondsToSelector:@selector(changeElementInSelectView:)]) {
            [self.customDelegate changeElementInSelectView:_selectView];
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
        switch (_titleWidthStyle) {
            case TitleWidthStyleDefault:
            {
                selectViewRect.size.width = button.frame.size.width * _fontGap + menuTitleLength;
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.origin.y = self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT;
                
                selectViewCenter.x = button.center.x;
            }
                break;
            case TitleWidthStyleSame:
            {
                selectViewRect.size.width = button.frame.size.width * _fontGap;
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.origin.y = self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT;
                
                selectViewCenter.x = button.center.x;
            }
                break;
            default:
                break;
        }
        
        if (_selectStyle & SelectStyleCustom) {
            selectViewRect.origin.y = 0;
            selectViewRect.size.height = self.frame.size.height;
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
    
    if ([self.customDelegate respondsToSelector:@selector(selectMenuSlide:relativelyViewWithViewIndex:)]) {
        [self.customDelegate selectMenuSlide:self relativelyViewWithViewIndex:_selectIndex];
    }
}

#pragma mark - selectView 滑动动画

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
                switch (_titleWidthStyle) {
                    case TitleWidthStyleDefault:
                    {
                        selectViewRect.size.width = selectTitleBtn.frame.size.width + menuTitleLength;
                        selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                        selectViewRect.origin.y = self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT;
                        
                        selectViewCenter.x = selectTitleBtn.center.x;
                    }
                        break;
                    case TitleWidthStyleSame:
                    {
                        selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                        selectViewRect.origin.y = self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT;
                        
                        selectViewCenter.x = selectTitleBtn.center.x;
                    }
                        break;
                    default:
                        break;
                }
                
                if (_selectStyle & SelectStyleCustom) {
                    selectViewRect.origin.y = 0;
                    selectViewRect.size.height = self.frame.size.height;
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

/**
 *     随着 SlideView 滑动的距离滑动
 */
-(void)scrollWith:(UICollectionView *)slideView
{
    if (_selectStyle == SelectStyleNone || isTapMenuTitleFlag) {
        return;
    }
    
    CGFloat slideViewContentOffX = slideView.contentOffset.x;
   
    // 第几页
    NSInteger item = slideViewContentOffX / slideView.frame.size.width + 1;
    
    if (item < 1) {
        [self fineTuneAndSelectItem:1];
        return;
    }else if (item >= [_menuTitleArray count]) {
        [self fineTuneAndSelectItem:[_menuTitleArray count]];
        return;
    }
    
    // 这一页滑动了多少
    CGFloat page_contentOffX = (CGFloat)((NSInteger)slideViewContentOffX % (NSInteger)slideView.frame.size.width);
    // 滑走的button
    UIButton * fromButton = (UIButton*)[self viewWithTag:item];
    // 滑向的button
    UIButton * toButton = (UIButton*)[self viewWithTag:item+1];
    // 这一页滑的百分比
    CGFloat scale = page_contentOffX / slideView.frame.size.width;
    
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
    if (self.contentSize.width > self.frame.size.width) {
        //    动画格式 并且改变 self contentOffset.x距离
        [self moveChangeAnimation:self.changeStyle];
    }
    
    if (_selectStyle & SelectStyleChangeFont) {
        //    改变滑动中 即将取消选择 和 选择的 cell 字号
        [self magnifyFontWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
    }
    
//        改变selectView滑动位置
    [self selectViewChangeWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
    
    if (_selectStyle & SelectStyleChangeColor) {
        //    改变滑动中 即将取消选择 和 选择的 cell 字体颜色
        [self ChangeSelectColorWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
    }
}

/**
 *     SlideView 结束滑动
 */
-(void)endScrollWith:(UICollectionView *)slideView
{
    if (_selectStyle == SelectStyleNone || isTapMenuTitleFlag) {
        return;
    }
    
    CGPoint pInView = [self convertPoint:slideView.center toView:slideView];
    NSIndexPath *indexPathNow = [slideView indexPathForItemAtPoint:pInView];
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
    switch (_titleWidthStyle) {
        case TitleWidthStyleDefault:
        {
            selectViewRect.size.width = selectBtn.frame.size.width + menuTitleLength;
            selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
            selectViewRect.origin.y = self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT;
            
            selectViewCenter.x = selectBtn.center.x;
        }
            break;
        case TitleWidthStyleSame:
        {
            selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
            selectViewRect.origin.y = self.frame.size.height - DEFAULT_SELECTVIEW_HEIGHT;
            
            selectViewCenter.x = selectBtn.center.x;
        }
            break;
        default:
            break;
    }
    
    if (_selectStyle & SelectStyleCustom) {
        selectViewRect.origin.y = 0;
        selectViewRect.size.height = self.frame.size.height;
    }
    
    _selectView.frame = selectViewRect;
    _selectView.center = selectViewCenter;
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
    
    switch (_titleWidthStyle) {
        case TitleWidthStyleDefault:
        {
            selectViewRect.size.width = (toButton.frame.size.width - fromButton.frame.size.width) * scale + fromButton.frame.size.width + menuTitleLength;
            selectViewCenter.x = fromButton.center.x + (toButton.center.x - fromButton.center.x)*scale;
        }
            break;
        case TitleWidthStyleSame:
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
        case ChangeStyleDefault:
        {
            [self changeSelectViewDefaultAnimation];
        }
            break;
        case ChangeStyleCenter:
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
    CGFloat selectViewPositionGaps = CGRectGetMaxX(_selectView.frame) - self.contentOffset.x;
    if (selectViewPositionGaps > self.frame.size.width) {
        [self setContentOffset:CGPointMake(self.contentOffset.x + (selectViewPositionGaps - self.frame.size.width), 0) animated:NO];
        if (self.contentOffset.x > self.contentSize.width - self.frame.size.width) {
            [self setContentOffset:CGPointMake(self.contentSize.width - self.frame.size.width, 0) animated:NO];
        }
    }else if (_selectView.frame.origin.x - self.contentOffset.x < 0) {
        [self setContentOffset:CGPointMake(_selectView.frame.origin.x, 0) animated:NO];
        if (self.contentOffset.x < 0) {
            [self setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }
}

/**
 *     scroll Center
 */
-(void)changeSelectViewCenterAnimation
{
    CGFloat selectViewPositionGaps = CGRectGetMaxX(_selectView.frame) - self.contentOffset.x;
    CGFloat left_right_Gap = (self.frame.size.width - _selectView.frame.size.width)/2.0f;
    if (selectViewPositionGaps > self.frame.size.width - left_right_Gap) {
        CGFloat move = _selectView.frame.origin.x - left_right_Gap;
        if (move > self.contentSize.width - self.frame.size.width) {
            move = self.contentSize.width - self.frame.size.width;
        }
        [self setContentOffset:CGPointMake(move, 0) animated:NO];
    }else if (_selectView.frame.origin.x - self.contentOffset.x < left_right_Gap) {
        CGFloat move = _selectView.frame.origin.x - left_right_Gap;
        if (move<0) {
            move = 0;
        }
        [self setContentOffset:CGPointMake(move, 0) animated:NO];
    }
}

@end
