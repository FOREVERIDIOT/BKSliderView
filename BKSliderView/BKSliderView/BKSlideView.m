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
     *  选中的titleBtn
     */
    UIButton * selectTitleBtn;
    
    /**
     *  是否是点击menuTitle翻页
     */
    BOOL isTapMenuTitleFlag;
    
    //第一次创建时调用 changeNowSelectIndex 方法
    BOOL firstCreateFlag;
}

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

#pragma mark - 刷新title滑动视图

-(void)reloadMenuView
{
    for (UIView * view in [_slideMenuView subviews]) {
        if (view.tag != 0 && [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self initAnyButton];
    
    if (_slideMenuViewHeight == 0) {
        [[_slideMenuView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
    }else{
        [[_slideMenuView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = NO;
        }];
    }
}

#pragma mark - 更新基础选项

-(void)setSlideMenuViewHeight:(CGFloat)slideMenuViewHeight
{
    _slideMenuViewHeight = slideMenuViewHeight;
    
    CGRect slideMenuViewRect = _slideMenuView.frame;
    slideMenuViewRect.size.height = _slideMenuViewHeight;
    _slideMenuView.frame = slideMenuViewRect;
    
    CGRect slideMenuBottomLineRect = _slideMenuBottomLine.frame;
    slideMenuBottomLineRect.origin.y = _slideMenuViewHeight - ONE_PIXEL;
    if (_slideMenuViewHeight == 0) {
        slideMenuBottomLineRect.size.height = 0;
    }else{
        slideMenuBottomLineRect.size.height = ONE_PIXEL;
    }
    _slideMenuBottomLine.frame = slideMenuBottomLineRect;
    
    CGRect slideViewRect = _slideView.frame;
    slideViewRect.origin.y = _slideMenuViewHeight;
    slideViewRect.size.height = _contentView.frame.size.height - _slideMenuViewHeight;
    _slideView.frame = slideViewRect;
    
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout*)_slideView.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height-_slideMenuViewHeight);
    _slideView.collectionViewLayout = layout;
    [_slideView reloadData];
    
    [self reloadMenuView];
}

-(void)setMenuTitleNumberOfLine:(CGFloat)menuTitleNumberOfLine
{
    _menuTitleNumberOfLine = menuTitleNumberOfLine;
    
    [self reloadMenuView];
}

-(void)setMenuTitleWidth:(CGFloat)menuTitleWidth
{
    _menuTitleWidth = menuTitleWidth;
    
    [self reloadMenuView];
}

-(void)setSlideMenuViewSelectStyle:(BKSlideMenuViewSelectStyle)slideMenuViewSelectStyle
{
    _slideMenuViewSelectStyle = slideMenuViewSelectStyle;
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        
    }else{
        _selectMenuTitleColor = _normalMenuTitleColor;
    }
    
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleHaveLine) {
        [_selectView setHidden:NO];
    }else{
        [_selectView setHidden:YES];
    }
    
    [self reloadMenuView];
}

-(void)setNormalMenuTitleFont:(UIFont *)normalMenuTitleFont
{
    _normalMenuTitleFont = normalMenuTitleFont;
    
    [self reloadMenuView];
}

-(void)setNormalMenuTitleColor:(UIColor *)normalMenuTitleColor
{
    _normalMenuTitleColor = normalMenuTitleColor;
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        
    }else{
        _selectMenuTitleColor = _normalMenuTitleColor;
    }
    [self reloadMenuView];
}

-(void)setSelectMenuTitleColor:(UIColor *)selectMenuTitleColor
{
    if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
        _selectMenuTitleColor = selectMenuTitleColor;
        [self reloadMenuView];
    }
}

#pragma mark - 改变选中

-(void)setSelectIndex:(NSInteger)selectIndex
{
    if (selectIndex > [_vcArray count]) {
        return;
    }
    _selectIndex = selectIndex;
    [self rollSlideViewToIndexView:_selectIndex];
}

#pragma mark - 改变选中view的属性

-(void)setSelectViewHeight:(CGFloat)selectViewHeight
{
    _selectViewHeight = selectViewHeight;
    if (_selectView) {
        
        CGRect frame = _selectView.frame;
        frame.size.height = _selectViewHeight;
        frame.origin.y = _slideMenuViewHeight - _selectViewHeight - _selectViewDistance;
        _selectView.frame = frame;
        
        _selectView.layer.cornerRadius = _selectView.frame.size.height/2.0f;
    }
}

-(void)setSelectViewDistance:(CGFloat)selectViewDistance
{
    _selectViewDistance = selectViewDistance;
    if (_selectView) {
        
        CGRect frame = _selectView.frame;
        frame.origin.y = _slideMenuViewHeight - _selectViewHeight - _selectViewDistance;
        _selectView.frame = frame;
    }
}

#pragma mark - 添加头视图

-(void)setHeaderView:(UIView *)headerView
{
    _headerView = headerView;
    
    [_bgScrollView addSubview:_headerView];
    
    CGRect contentViewRect = _contentView.frame;
    contentViewRect.origin.y = CGRectGetMaxY(_headerView.frame);
    _contentView.frame = contentViewRect;
    
    [self changeBgScrollContentSizeWithNowIndex:_selectIndex isScrollEnd:YES];
}


/**
 获取主视图内的scrollview
 
 @return 主视图内的scrollview
 */
-(UIScrollView*)getFrontScrollViewWithNowIndex:(NSInteger)index
{
    UIViewController * vc = _vcArray[index];
    
    __block UIScrollView * scrollView;
    [[vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            scrollView = obj;
        }
    }];
    
    return scrollView;
}


/**
 根据主视图内容改变 bgScrollview 的 contentSize
 
 @param index 第几页
 @param isScrollEnd slideView是否滑动结束
 */
-(void)changeBgScrollContentSizeWithNowIndex:(NSInteger)index isScrollEnd:(BOOL)isScrollEnd
{
    if (_headerView) {
        UIScrollView * scrollView = [self getFrontScrollViewWithNowIndex:index];
        
        //是否主视图内 scrollview的contentSize.height 小于 自身height
        BOOL flag = NO;
        if (scrollView) {
            
            scrollView.scrollEnabled = NO;
            
            if (scrollView.contentSize.height > scrollView.frame.size.height) {
                
                CGFloat contentSizeHeight = scrollView.contentSize.height + _headerView.frame.size.height + _slideMenuViewHeight;
                
                if (contentSizeHeight > _bgScrollView.contentSize.height) {
                    _bgScrollView.contentSize = CGSizeMake(_bgScrollView.frame.size.width, contentSizeHeight);
                }
                
                if (_bgScrollView.contentOffset.y < _headerView.frame.size.height) {
                    scrollView.contentOffset = CGPointZero;
                }else {
                    if (index == _selectIndex) {
                        _bgScrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + _headerView.frame.size.height);
                    }
                }
                
                if (isScrollEnd && contentSizeHeight != _bgScrollView.contentSize.height) {
                    _bgScrollView.contentSize = CGSizeMake(_bgScrollView.frame.size.width, contentSizeHeight);
                }
                
            }else{
                flag = YES;
            }
            
        }else{
            flag = YES;
        }
        
        if (flag) {
            
            CGFloat contentSizeHeight = _headerView.frame.size.height + _contentView.frame.size.height;;
            
            if (contentSizeHeight > _bgScrollView.contentSize.height) {
                _bgScrollView.contentSize = CGSizeMake(_bgScrollView.frame.size.width, contentSizeHeight);
            }
            
            if (_bgScrollView.contentOffset.y < _headerView.frame.size.height) {
                
            }else{
                if (index == _selectIndex) {
                    _bgScrollView.contentOffset = CGPointMake(0, _headerView.frame.size.height);
                }
            }
            
            if (isScrollEnd && contentSizeHeight != _bgScrollView.contentSize.height) {
                _bgScrollView.contentSize = CGSizeMake(_bgScrollView.frame.size.width, contentSizeHeight);
            }
        }
    }
}

#pragma mark - 内容视图

-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:_bgScrollView.bounds];
        _contentView.clipsToBounds = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        
        /**
         *  title滑动视图
         */
        [self initSlideMenuView];
        
        if (!_slideMenuBottomLine) {
            _slideMenuBottomLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, _slideMenuView.frame.size.height - ONE_PIXEL, _slideMenuView.frame.size.width, ONE_PIXEL)];
            _slideMenuBottomLine.backgroundColor = [UIColor clearColor];
            [_contentView addSubview:_slideMenuBottomLine];
        }
        
        /**
         *  滑动主视图
         */
        [self initSlideView];
        
        [_bgScrollView addSubview:_contentView];
    }
    return _contentView;
}

#pragma mark - 初始

-(instancetype)initWithFrame:(CGRect)frame vcArray:(NSArray *)vcArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self initData];
        
        firstCreateFlag = YES;
        self.clipsToBounds = NO;
        _vcArray = [NSArray arrayWithArray:vcArray];
        
        //背景滚动视图(竖直方向)
        [self bgScrollView];
        //内容视图
        [self contentView];
        
        _bgScrollView.contentSize = CGSizeMake(_bgScrollView.frame.size.width, CGRectGetMaxY(_contentView.frame));
    }
    
    return self;
}

-(void)initData
{
    _slideMenuViewHeight = SLIDE_MENU_VIEW_HEIGHT;
    _menuTitleNumberOfLine = 1;
    
    _selectViewHeight = DEFAULT_SELECTVIEW_HEIGHT;
    _selectViewDistance = 0;
    
    _normalMenuTitleFont = [UIFont systemFontOfSize:NORMAL_TITLE_FONT];
    
    _normalMenuTitleColor = NORMAL_TITLE_COLOR;
    _selectMenuTitleColor = SELECT_TITLE_COLOR;
    
    _slideMenuViewSelectStyle = SlideMenuViewSelectStyleHaveLine | SlideMenuViewSelectStyleChangeColor;
}

-(void)changeNowSelectIndex
{
    if ([_delegate respondsToSelector:@selector(slideView:nowShowSelectIndex:)]) {
        [_delegate slideView:self nowShowSelectIndex:_selectIndex];
    }
    
    [self changeBgScrollContentSizeWithNowIndex:_selectIndex isScrollEnd:YES];
}

#pragma mark - 背景滚动视图

-(UIScrollView *)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.delegate = self;
        _bgScrollView.clipsToBounds = NO;
        [self addSubview:_bgScrollView];
    }
    return _bgScrollView;
}

#pragma mark - 选取title滑动视图

-(void)initSlideMenuView
{
    _slideMenuView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, _slideMenuViewHeight)];
    _slideMenuView.backgroundColor = [UIColor whiteColor];
    _slideMenuView.showsHorizontalScrollIndicator = NO;
    _slideMenuView.showsVerticalScrollIndicator = NO;
    _slideMenuView.clipsToBounds = NO;
    [_contentView addSubview:_slideMenuView];
    
    [self initAnyButton];
}

-(void)initAnyButton
{
    __block UIView * lastView;
    
    [_vcArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIViewController * vc = (UIViewController*)obj;
        
        UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake((lastView?CGRectGetMaxX(lastView.frame):0), 0, 0, _slideMenuViewHeight);
        titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleBtn.titleLabel.numberOfLines = _menuTitleNumberOfLine;
        titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [titleBtn setBackgroundColor:[UIColor clearColor]];
        [titleBtn setTitle:vc.title forState:UIControlStateNormal];
        [titleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
        titleBtn.titleLabel.font = _normalMenuTitleFont;
        titleBtn.clipsToBounds = NO;
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
            [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
        }
        [_slideMenuView addSubview:titleBtn];
        
        lastView = titleBtn;
    }];
    
    _slideMenuView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), _slideMenuViewHeight);
    
    if (!_selectView) {
        [_slideMenuView addSubview:self.selectView];
    }else{
        
        CGRect rect = _selectView.frame;
        rect.size.width = [self changeWidthView:selectTitleBtn.titleLabel];
        rect.origin.y = _slideMenuViewHeight - _selectViewHeight - _selectViewDistance;
        _selectView.frame = rect;
        
        CGPoint selectViewCenter = _selectView.center;
        selectViewCenter.x = selectTitleBtn.center.x;
        _selectView.center = selectViewCenter;
    }
}

-(UIView*)selectView
{
    if (!_selectView) {
        
        CGFloat width = [self changeWidthView:selectTitleBtn.titleLabel];
        
        _selectView = [[UIView alloc]initWithFrame:CGRectMake(0,_slideMenuViewHeight - _selectViewHeight - _selectViewDistance ,width ,_selectViewHeight)];
        
        CGPoint selectViewCenter = _selectView.center;
        selectViewCenter.x = selectTitleBtn.center.x;
        _selectView.center = selectViewCenter;
        
        _selectView.backgroundColor = [UIColor blackColor];
        _selectView.layer.cornerRadius = _selectView.frame.size.height/2.0f;
        _selectView.clipsToBounds = YES;
    }
    return _selectView;
}

#pragma mark - 内容长度计算

-(CGSize)sizeWithString:(NSString *)string UIHeight:(CGFloat)height font:(UIFont*)font
{
    if (!string || !font) {
        return CGSizeZero;
    }
    
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

#pragma mark - 滑动主视图

-(void)initSlideView
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height-_slideMenuViewHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _slideView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _slideMenuViewHeight, _contentView.frame.size.width, _contentView.frame.size.height - _slideMenuViewHeight) collectionViewLayout:layout];
    _slideView.showsHorizontalScrollIndicator = NO;
    _slideView.showsVerticalScrollIndicator = NO;
    _slideView.delegate = self;
    _slideView.dataSource = self;
    _slideView.backgroundColor = [UIColor clearColor];
    _slideView.pagingEnabled = YES;
    [_contentView addSubview:_slideView];
    
    [_slideView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"slideView"];
    
    [self bringSubviewToFront:_slideMenuView];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_vcArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"slideView" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIViewController *vc = _vcArray[indexPath.item];
    vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell addSubview:vc.view];
    
    if (![self.createIndexArr containsObject:indexPath]) {
        [self.createIndexArr addObject:indexPath];
        if ([_delegate respondsToSelector:@selector(slideView:createVCWithIndex:)]) {
            [_delegate slideView:self createVCWithIndex:indexPath.item];
        }
    }
    
    if (firstCreateFlag) {
        [self changeNowSelectIndex];
        firstCreateFlag = NO;
    }else{
        [self changeBgScrollContentSizeWithNowIndex:indexPath.item isScrollEnd:NO];
    }
}

#pragma mark - UIButton

-(void)titleBtnClick:(UIButton*)button
{
    if (isTapMenuTitleFlag || button == selectTitleBtn) {
        return;
    }
    isTapMenuTitleFlag = YES;
    
    if ([_delegate respondsToSelector:@selector(slideView:nowLeaveIndex:)]) {
        [_delegate slideView:self nowLeaveIndex:_selectIndex];
    }
    
    [selectTitleBtn setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
    [button setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
    
    CGRect selectViewRect = button.frame;
    CGPoint selectViewCenter = _selectView.center;
    
    selectViewRect.size.width = [self changeWidthView:button.titleLabel];
    selectViewRect.origin.y = _slideMenuViewHeight - _selectViewHeight - _selectViewDistance;
    selectViewRect.size.height = _selectViewHeight;
    selectViewCenter.x = button.center.x;
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _selectView.frame = selectViewRect;
        _selectView.center = selectViewCenter;
        
        if (_slideMenuView.contentSize.width > _slideMenuView.frame.size.width) {
            //    动画格式 并且改变 self contentOffset.x距离
            [self changeSelectViewCenterAnimation];
        }
        
    } completion:^(BOOL finished) {
        
        selectTitleBtn = button;
        isTapMenuTitleFlag = NO;
    }];
    
    CGFloat rollLength = _slideView.frame.size.width * (button.tag-1);
    [_slideView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fineTuneAndSelectItem:button.tag];
        [self changeNowSelectIndex];
    });
}

/**
 *     移动 SlideView 至第 index 页
 */
-(void)rollSlideViewToIndexView:(NSInteger)index
{
    UIButton * button = [_slideMenuView viewWithTag:index+1];
    [self titleBtnClick:button];
}

#pragma mark - 调整选中

/**
 *  略微调整选中状态的显示
 *
 *  @param item 选中的item 从1开始
 */
-(void)fineTuneAndSelectItem:(NSInteger)item
{
    [[_slideMenuView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag != 0 && [obj isKindOfClass:[UIButton class]]) {
            UIButton * button = (UIButton*)obj;
            
            if (item == button.tag) {
                selectTitleBtn = button;
                _selectIndex = item-1;
                
                [selectTitleBtn setTitleColor:_selectMenuTitleColor forState:UIControlStateNormal];
                
                CGRect selectViewRect = selectTitleBtn.frame;
                CGPoint selectViewCenter = _selectView.center;
                
                selectViewRect.size.width = [self changeWidthView:button.titleLabel];
                selectViewRect.origin.y = _slideMenuViewHeight - _selectViewHeight - _selectViewDistance;
                selectViewRect.size.height = _selectViewHeight;
                selectViewCenter.x = selectTitleBtn.center.x;
                
                _selectView.frame = selectViewRect;
                _selectView.center = selectViewCenter;
                
            }else{
                [button setTitleColor:_normalMenuTitleColor forState:UIControlStateNormal];
            }
        }
    }];
}

#pragma mark - UIScrollDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _slideView) {
        if ([_delegate respondsToSelector:@selector(slideView:nowLeaveIndex:)]) {
            [_delegate slideView:self nowLeaveIndex:_selectIndex];
        }
        
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    }else if (scrollView == _bgScrollView) {
        [self changeBgScrollContentSizeWithNowIndex:_selectIndex isScrollEnd:YES];
        
        if ([_delegate respondsToSelector:@selector(slideView:willBeginDraggingBgScrollView:)]) {
            [_delegate slideView:self willBeginDraggingBgScrollView:_bgScrollView];
        }
    }
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
        
        //        改变selectView滑动位置
        [self selectViewChangeWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
        
        /**
         *  滑动中所做的动画
         */
        if (_slideMenuView.contentSize.width > _slideMenuView.frame.size.width) {
            //    动画格式 并且改变 self contentOffset.x距离
            [self changeSelectViewCenterAnimation];
        }
        
        if (_slideMenuViewSelectStyle & SlideMenuViewSelectStyleChangeColor) {
            //    改变滑动中 即将取消选择 和 选择的 cell 字体颜色
            [self ChangeSelectColorWithFromButton:now_frombutton toButton:now_toButton scale:now_scale];
        }
    }else if (_bgScrollView == scrollView) {
        
        if ([self.delegate respondsToSelector:@selector(slideView:didScrollBgScrollView:)]) {
            [self.delegate slideView:self didScrollBgScrollView:_bgScrollView];
        }
        
        if (_headerView) {
            
            CGFloat contentOffSetY = _bgScrollView.contentOffset.y;
            
            UIScrollView * scrollView = [self getFrontScrollViewWithNowIndex:_selectIndex];
            
            if (contentOffSetY > _headerView.frame.size.height) {
                
                CGRect contentViewRect = _contentView.frame;
                contentViewRect.origin.y = contentOffSetY;
                _contentView.frame = contentViewRect;
                
                if (scrollView) {
                    scrollView.contentOffset = CGPointMake(0, contentOffSetY - _headerView.frame.size.height);
                }
            }else{
                
                CGRect contentViewRect = _contentView.frame;
                contentViewRect.origin.y = CGRectGetMaxY(_headerView.frame);
                _contentView.frame = contentViewRect;
                
                if (scrollView) {
                    scrollView.contentOffset = CGPointZero;
                }
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == _slideView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        });
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if (scrollView == _slideView) {
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        }
    }
    
    if (scrollView == _bgScrollView) {
        
        if ([_delegate respondsToSelector:@selector(slideView:didEndDraggingBgScrollView:willDecelerate:)]) {
            [_delegate slideView:self didEndDraggingBgScrollView:_bgScrollView willDecelerate:decelerate];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _slideView) {
        
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        
        if (_slideMenuViewSelectStyle == SlideMenuViewSelectStyleNone || isTapMenuTitleFlag) {
            return;
        }
        
        CGPoint point = [self convertPoint:self.center toView:_slideView];
        NSIndexPath * indexPath = [_slideView indexPathForItemAtPoint:point];
        NSInteger item = indexPath.item;
        
        [self fineTuneAndSelectItem:item+1];
        [self changeNowSelectIndex];
    }else if (scrollView == _bgScrollView) {
        
        if ([_delegate respondsToSelector:@selector(slideView:didEndDeceleratingBgScrollView:)]) {
            [_delegate slideView:self didEndDeceleratingBgScrollView:_bgScrollView];
        }
    }
}

#pragma mark - 滑动动画

/**
 *     selectView 改变滑动位置
 */
-(void)selectViewChangeWithFromButton:(UIButton*)fromButton toButton:(UIButton*)toButton scale:(CGFloat)scale
{
    CGRect selectViewRect = _selectView.frame;
    CGPoint selectViewCenter = _selectView.center;
    
    CGFloat fromWidth = [self changeWidthView:fromButton.titleLabel];
    CGFloat toWidth = [self changeWidthView:toButton.titleLabel];
    
    selectViewRect.size.width = (toWidth - fromWidth) * scale + fromWidth;
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

#pragma mark - slideMenuView 动画格式

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
        if (move < 0) {
            move = 0;
        }
        [_slideMenuView setContentOffset:CGPointMake(move, 0) animated:NO];
    }
}

@end
