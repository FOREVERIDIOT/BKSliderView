//
//  BKSlideView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKSlideView.h"
#import "objc/runtime.h"

@interface BKSlideView()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    /**
     *  是否初始化完毕
     */
    BOOL isInitFinishFlag;
   
    /**
     *  选中的titleBtn
     */
    UIButton * selectTitleBtn;
    
    /**
     *  是否是点击menuTitle翻页
     */
    BOOL isTapMenuTitleFlag;
}

@property (nonatomic,strong) dispatch_queue_t myQueue;

/**
 记录创建过的vc数组
 */
@property (nonatomic,strong) NSMutableArray * createIndexArr;

@end

@implementation BKSlideView

-(NSMutableArray*)createIndexArr
{
    if (!_createIndexArr) {
        _createIndexArr = [NSMutableArray array];
    }
    return _createIndexArr;
}

#pragma mark - 刷新

-(dispatch_queue_t)myQueue
{
    if (!_myQueue) {
        _myQueue = dispatch_queue_create("myQueue", nil);
    }
    
    return _myQueue;
}

-(void)reloadView
{
    dispatch_async(self.myQueue, ^{
        if (isInitFinishFlag) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (UIView * view in [_slideMenuView subviews]) {
                    if (view.tag != 0 && [view isKindOfClass:[UIButton class]]) {
                        [view removeFromSuperview];
                    }
                }
                
                [self initAnyButton];
            });
        }
    });
}

-(void)setMenuTitleWidth:(CGFloat)menuTitleWidth
{
    _menuTitleWidth = menuTitleWidth;
    [self reloadView];
}

-(void)setSlideMenuViewSelectStyle:(BKSlideMenuViewSelectStyle)slideMenuViewSelectStyle
{
    _slideMenuViewSelectStyle = slideMenuViewSelectStyle;
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeFont) {
        
    }else{
        _fontGap = 1;
    }
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        
    }else{
        _selectMenuTitleColor = _normalMenuTitleColor;
    }
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleHaveLine) {
        [_selectView setHidden:NO];
    }else{
        [_selectView setHidden:YES];
    }
    
    [self reloadView];
}

-(void)setNormalMenuTitleFont:(UIFont *)normalMenuTitleFont
{
    _normalMenuTitleFont = normalMenuTitleFont;
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeFont) {
        
    }else{
        _fontGap = 1;
    }
    [self reloadView];
}

-(void)setFontGap:(CGFloat)fontGap
{
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeFont) {
        _fontGap = fontGap;
        [self reloadView];
    }
}

-(void)setNormalMenuTitleColor:(UIColor *)normalMenuTitleColor
{
    _normalMenuTitleColor = normalMenuTitleColor;
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        
    }else{
        _selectMenuTitleColor = _normalMenuTitleColor;
    }
    [self reloadView];
}

-(void)setSelectMenuTitleColor:(UIColor *)selectMenuTitleColor
{
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        _selectMenuTitleColor = selectMenuTitleColor;
        [self reloadView];
    }
}

#pragma mark - 改变选中

-(void)setSelectIndex:(NSInteger)selectIndex
{
    if (selectIndex > [_vcArray count]) {
        return;
    }
    _selectIndex = selectIndex;
    [self reloadView];
}

#pragma mark - 初始

-(instancetype)initWithFrame:(CGRect)frame vcArray:(NSArray *)vcArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _vcArray = [NSArray arrayWithArray:vcArray];
        
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

-(void)setDelegate:(id<BKSlideViewDelegate>)delegate
{
    if (delegate) {
        _delegate = delegate;
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_selectIndex inSection:0];
        UICollectionViewCell * cell = [self.slideView cellForItemAtIndexPath:indexPath];
        if (cell) {
        
            UIViewController *vc = _vcArray[indexPath.item];
            vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:vc.view];
            
            if ([self.delegate respondsToSelector:@selector(slideView:createVCWithIndex:)]) {
                if (![self.createIndexArr containsObject:indexPath]) {
                    [self.createIndexArr addObject:indexPath];
                    [self.delegate slideView:self createVCWithIndex:_selectIndex];
                }
            }
        }
        
        [self addObserver:self forKeyPath:@"selectIndex" options:NSKeyValueObservingOptionNew context:nil];
        if ([_delegate respondsToSelector:@selector(slideView:nowShowSelectIndex:)]) {
            [_delegate slideView:self nowShowSelectIndex:_selectIndex];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectIndex"]) {
        if ([self.delegate respondsToSelector:@selector(slideView:nowShowSelectIndex:)]) {
            [self.delegate slideView:self nowShowSelectIndex:[change[@"new"] integerValue]];
        }
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectIndex"];
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
    
    isInitFinishFlag = YES;
}

-(void)initData
{
    self.selectIndex = 0;
    
    _normalMenuTitleFont = [UIFont systemFontOfSize:NORMAL_TITLE_FONT];
    _fontGap = FONT_GAP;
    
    _normalMenuTitleColor = NORMAL_TITLE_COLOR;
    _selectMenuTitleColor = SELECT_TITLE_COLOR;
    
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
    
    [_vcArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIViewController * vc = (UIViewController*)obj;
        
        UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake((lastView?CGRectGetMaxX(lastView.frame):0), 0, 0, SLIDE_MENU_VIEW_HEIGHT);
        titleBtn.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
        [titleBtn setBackgroundColor:[UIColor clearColor]];
        [titleBtn setTitle:vc.title forState:UIControlStateNormal];
        [titleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        titleBtn.titleLabel.font = _normalMenuTitleFont;
        titleBtn.adjustsImageWhenHighlighted = NO;
        titleBtn.tag = idx + 1;
        
        CGRect titleRect = titleBtn.frame;
        if (!_menuTitleWidth) {
            titleRect.size.width = [self changeWidthView:titleBtn.titleLabel] + TITLE_ADD_GAP;
        }else{
            titleRect.size.width = _menuTitleWidth;
        }
        titleBtn.frame = titleRect;
        
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (titleBtn.tag == _selectIndex+1) {
            selectTitleBtn = titleBtn;
        }
        [_slideMenuView addSubview:titleBtn];
        
        lastView = titleBtn;
    }];
    
    _slideMenuView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), SLIDE_MENU_VIEW_HEIGHT);
    
    [self initSelectView];
}

-(void)initSelectView
{
    [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
    selectTitleBtn.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
    
    if (![[_slideMenuView subviews] containsObject:self.selectView]) {
        [_slideMenuView addSubview:[self selectView]];
    }
    
    _selectView.frame = CGRectMake(0,SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT,selectTitleBtn.frame.size.width,DEFAULT_SELECTVIEW_HEIGHT);
    CGPoint selectViewCenter = _selectView.center;
    selectViewCenter.x = selectTitleBtn.center.x;
    _selectView.center = selectViewCenter;
}

-(UIView*)selectView
{
    if (!_selectView) {
        _selectView = [[UIView alloc]initWithFrame:CGRectMake(0,SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT,selectTitleBtn.frame.size.width,DEFAULT_SELECTVIEW_HEIGHT)];
        _selectView.backgroundColor = [UIColor blackColor];
        _selectView.layer.cornerRadius = _selectView.frame.size.height/2.0f;
        _selectView.clipsToBounds = YES;
    }
    return _selectView;
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
    
    [self bringSubviewToFront:_slideMenuView];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_vcArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"slideView" forIndexPath:indexPath];

    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIViewController *vc = _vcArray[indexPath.item];
    vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell.contentView addSubview:vc.view];
    
    if ([self.delegate respondsToSelector:@selector(slideView:createVCWithIndex:)]) {
        if (![self.createIndexArr containsObject:indexPath]) {
            [self.createIndexArr addObject:indexPath];
            [self.delegate slideView:self createVCWithIndex:indexPath.item];
        }
    }

    return cell;
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
        
        selectViewRect.size.width = button.frame.size.width * _fontGap;
        selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
        selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
        selectViewCenter.x = button.center.x;
        
        selectTitleBtn = (UIButton*)[_slideMenuView viewWithTag:_selectIndex+1];
        [selectTitleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        [button setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            _selectView.frame = selectViewRect;
            _selectView.center = selectViewCenter;
            
            selectTitleBtn.transform = CGAffineTransformMakeScale(1, 1);
            button.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
            
            if (_slideMenuView.contentSize.width > self.frame.size.width) {
                //    动画格式 并且改变 self contentOffset.x距离
                [self moveChangeAnimation:self.slideMenuViewChangeStyle];
            }
            
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
    
    self.selectIndex = button.tag-1;
    
    CGFloat rollLength = _slideView.frame.size.width * (_selectIndex);
    [_slideView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

/**
 *     移动 SlideView 至第 index 页
 */
-(void)rollSlideViewToIndexView:(NSInteger)index
{
    UIButton * button = [_slideMenuView viewWithTag:index+1];
    [self titleBtnClick:button];
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
                _selectIndex = item-1;
                
                [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
                selectTitleBtn.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
                
                CGRect selectViewRect = selectTitleBtn.frame;
                CGPoint selectViewCenter = _selectView.center;
                
                selectViewRect.size.width = selectTitleBtn.frame.size.width;
                selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT - DEFAULT_SELECTVIEW_HEIGHT;
                selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
                selectViewCenter.x = selectTitleBtn.center.x;
                
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
        }else if (item >= [_vcArray count]) {
            [self fineTuneAndSelectItem:[_vcArray count]];
            return;
        }
        
        // 这一页滑动了多少
        CGFloat page_contentOffX = (CGFloat)((NSInteger)slideViewContentOffX % (NSInteger)_slideView.frame.size.width);
        // 滑走的button
        UIButton * fromButton = (UIButton*)[_slideMenuView viewWithTag:item];
        // 滑向的button
        UIButton * toButton = (UIButton*)[_slideMenuView viewWithTag:item+1];
        // 这一页滑的百分比
        CGFloat scale = page_contentOffX / _slideView.frame.size.width;
        
        if (scale == 0) {
            [self fineTuneAndSelectItem:item];
            return;
        }
        
        if (scale < 0.5) {
            UIButton * button = (UIButton*)[_slideMenuView viewWithTag:item];
            selectTitleBtn = button;
            _selectIndex = item-1;
        }
        
        // 根据方向从新控制滑向的button 和 百分比
        CGFloat now_scale = 0.0;
        UIButton * now_frombutton;
        UIButton * now_toButton;
        if (selectTitleBtn == fromButton || selectTitleBtn.tag == fromButton.tag) {
            now_scale = scale;
            now_frombutton = fromButton;
            now_toButton = toButton;
        }else if (selectTitleBtn == toButton || selectTitleBtn.tag == toButton.tag) {
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
        
        self.selectIndex = item;
        UIButton * selectBtn = (UIButton*)[_slideMenuView viewWithTag:_selectIndex+1];
        
        selectTitleBtn.transform = CGAffineTransformMakeScale(1, 1);
        [selectTitleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        selectTitleBtn = selectBtn;
        [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
        selectTitleBtn.transform = CGAffineTransformMakeScale(_fontGap, _fontGap);
        
        CGRect selectViewRect = selectBtn.frame;
        CGPoint selectViewCenter = _selectView.center;
        
        selectViewRect.size.width = selectBtn.frame.size.width;
        selectViewRect.origin.y = SLIDE_MENU_VIEW_HEIGHT-DEFAULT_SELECTVIEW_HEIGHT;
        selectViewRect.size.height = DEFAULT_SELECTVIEW_HEIGHT;
        selectViewCenter.x = selectBtn.center.x;
        
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
    
    selectViewRect.size.width = (toButton.frame.size.width - fromButton.frame.size.width) * scale + fromButton.frame.size.width;
    selectViewCenter.x = fromButton.center.x + (toButton.center.x - fromButton.center.x)*scale;
    
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
    if (selectViewPositionGaps > _slideMenuView.frame.size.width) {
        [_slideMenuView setContentOffset:CGPointMake(_slideMenuView.contentOffset.x + (selectViewPositionGaps - _slideMenuView.frame.size.width), 0) animated:NO];
        if (_slideMenuView.contentOffset.x > _slideMenuView.contentSize.width - _slideMenuView.frame.size.width) {
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
    CGFloat left_right_Gap = (_slideMenuView.frame.size.width - _selectView.frame.size.width)/2.0f;
    if (selectViewPositionGaps > _slideMenuView.frame.size.width - left_right_Gap) {
        CGFloat move = _selectView.frame.origin.x - left_right_Gap;
        if (move > _slideMenuView.contentSize.width - _slideMenuView.frame.size.width) {
            move = _slideMenuView.contentSize.width - _slideMenuView.frame.size.width;
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
