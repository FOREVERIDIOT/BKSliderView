//
//  BKSliderView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#import "BKSliderView.h"
#import "UIView+BKSliderView.h"

NSString * const kSliderViewCellID = @"kSliderViewCellID";

@interface BKSliderView()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BKSliderMenuViewDelegate,UIGestureRecognizerDelegate>

/**
 已经存在的vc
 */
@property (nonatomic,strong) NSMutableArray * existingViewControllers;

/**
 离开的index
 */
@property (nonatomic,assign) NSInteger leaveIndex;

/**
 主视图是否正在滚动中
 */
@property (nonatomic,assign) BOOL bgScrollViewIsScrolling;

@end

@implementation BKSliderView
@synthesize csCollectionViewPanGesture = _csCollectionViewPanGesture;

#pragma mark - 展示的vc数组

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
{
    _viewControllers = viewControllers;
    NSMutableArray * titles = [NSMutableArray array];
    for (UIViewController * vc in _viewControllers) {
        NSAssert(vc.title != nil, @"未创建标题");
        NSUInteger existCount = 0;
        for (UIViewController * vc2 in _viewControllers) {
            if ([vc.title isEqualToString:vc2.title]) {
                existCount++;
            }
        }
        NSAssert(existCount == 1, @"创建标题重复");
        [titles addObject:vc.title];
    }
    [self.collectionView reloadData];
    
    self.menuView.titles = titles;
}

#pragma mark - 选中的索引

-(void)setSelectIndex:(NSUInteger)selectIndex
{
    if (selectIndex > [self.viewControllers count] - 1) {
        _selectIndex = [self.viewControllers count] - 1;
    }else {
        _selectIndex = selectIndex;
    }
    self.menuView.selectIndex = _selectIndex;
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BKSliderViewDelegate>)delegate viewControllers:(NSArray *)viewControllers
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.viewControllers = viewControllers;
        
        [self initUI];
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        self.bgScrollView.frame = self.bounds;
        if (![[self.bgScrollView subviews] containsObject:self.headerView]) {
            self.contentView.frame = CGRectMake(0, 0, self.bgScrollView.bk_width, self.bgScrollView.bk_height);
        }else {
            if (self.bgScrollView.contentOffset.y > self.headerView.bk_height) {
                self.contentView.frame = CGRectMake(0, self.bgScrollView.contentOffset.y, self.bgScrollView.bk_width, self.bgScrollView.bk_height);
            }else {
                self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.bgScrollView.bk_width, self.bgScrollView.bk_height);
            }
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgScrollView.frame = CGRectMake(0, 0, self.bk_width, self.bk_height);
    if (![[self.bgScrollView subviews] containsObject:self.headerView]) {
        self.contentView.frame = CGRectMake(0, 0, self.bgScrollView.bk_width, self.bgScrollView.bk_height);
    }else {
        if (self.bgScrollView.contentOffset.y > self.headerView.bk_height) {
            self.contentView.frame = CGRectMake(0, self.bgScrollView.contentOffset.y, self.bgScrollView.bk_width, self.bgScrollView.bk_height);
        }else {
            self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.bgScrollView.bk_width, self.bgScrollView.bk_height);
        }
    }
    self.menuView.frame = CGRectMake(0, 0, self.contentView.bk_width, self.menuView.bk_height);
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.menuView.frame), self.contentView.bk_width, self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame));
}

#pragma - 初始化UI

-(void)initUI
{
    [self addSubview:self.bgScrollView];
    [self.bgScrollView addSubview:self.contentView];
    [self.contentView addSubview:self.menuView];
    [self.contentView insertSubview:self.collectionView belowSubview:self.menuView];
}

#pragma mark - 主视图

-(UIScrollView*)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, self.bk_height)];
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _bgScrollView;
}

#pragma mark - 第二级视图
#pragma mark - 头视图

-(void)setHeaderView:(UIView *)headerView
{
    _headerView = headerView;
    
    [self.bgScrollView addSubview:_headerView];
    self.contentView.bk_y = CGRectGetMaxY(_headerView.frame);
    
    [self changeBgScrollContentSizeWithNowIndex:self.selectIndex isScrollEnd:YES];
}

/**
 根据详情内容视图内容长度(比如UIScrollView的contentSize.height)改变主视图的contentSize.height
 
 @param index 第几页
 @param isScrollEnd sliderView是否滑动结束
 */
-(void)changeBgScrollContentSizeWithNowIndex:(NSInteger)index isScrollEnd:(BOOL)isScrollEnd
{
    if (_headerView) {
        //获取当前详情内容视图内的滚动视图
        UIScrollView * scrollView = [self getFrontScrollViewWithNowIndex:index];
        //如果详情内容视图中包含滚动视图 禁止滚动视图滑动能力
        if (scrollView) {//有滚动视图
            scrollView.scrollEnabled = NO;
            //滚动视图的contentSize.height > 滚动视图自身height
            if (scrollView.contentSize.height > scrollView.bk_height) {
                //所有内容高度 = 头视图高度 + 导航视图高度 + 滚动视图的内容高度
                CGFloat contentSizeHeight = self.headerView.bk_height + self.menuView.bk_height + scrollView.contentSize.height;
                //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
                if (contentSizeHeight > self.bgScrollView.contentSize.height) {
                    self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.bk_width, contentSizeHeight);
                }
                
                if (self.bgScrollView.contentOffset.y < self.headerView.bk_height) {
                    //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                    scrollView.contentOffset = CGPointZero;
                }else {
                    //如果主视图滑动高度 > 头视图高度 根据滚动视图的滑动高度修改主视图滑动高度
                    if (index == self.selectIndex) {
                        self.bgScrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + self.headerView.bk_height);
                    }
                }
                //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
                if (isScrollEnd && contentSizeHeight != self.bgScrollView.contentSize.height) {
                    self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.bk_width, contentSizeHeight);
                }
                return;
            }
        }
        //有滚动视图 || 滚动视图的contentSize.height < 滚动视图自身height
        //所有内容高度 = 头视图高度 + 详情内容视图高度
        CGFloat contentSizeHeight = self.headerView.bk_height + self.contentView.bk_height;
        //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
        if (contentSizeHeight > self.bgScrollView.contentSize.height) {
            self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.bk_width, contentSizeHeight);
        }
        
        if (self.bgScrollView.contentOffset.y < self.headerView.bk_height) {
            //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
            scrollView.contentOffset = CGPointZero;
        }else{
            //如果主视图滑动高度 > 头视图高度 修改主视图滑动高度
            if (index == self.selectIndex) {
                self.bgScrollView.contentOffset = CGPointMake(0, self.headerView.bk_height);
            }
        }
        //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
        if (isScrollEnd && contentSizeHeight != self.bgScrollView.contentSize.height) {
            self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.bk_width, contentSizeHeight);
        }
    }
}

/**
 获取内容视图内的scrollview
 
 @return 内容视图内的scrollview
 */
-(UIScrollView*)getFrontScrollViewWithNowIndex:(NSInteger)index
{
    UIViewController * vc = self.viewControllers[index];
    
    __block UIScrollView * scrollView;
    [[vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            scrollView = obj;
        }
    }];
    
    return scrollView;
}

#pragma mark - 内容视图

-(UIView*)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bgScrollView.bk_width, self.bgScrollView.bk_height)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

#pragma mark - 第三级视图
#pragma mark - 导航视图

-(BKSliderMenuView*)menuView
{
    if (!_menuView) {
        _menuView = [[BKSliderMenuView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bk_width, 45)];
        _menuView.delegate = self;
    }
    return _menuView;
}

#pragma mark - BKSliderMenuViewDelegate

-(void)changeMenuViewFrame
{
    self.collectionView.bk_y = CGRectGetMaxY(self.menuView.frame);
    self.collectionView.bk_height = self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame);
    [self.collectionView reloadData];
}

-(void)switchingSelectIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
{
    if (switchingIndex > [self.viewControllers count] - 1 || switchingIndex < 0 || leavingIndex > [self.viewControllers count] - 1 || leavingIndex < 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(sliderView:switchingIndex:leavingIndex:percentage:)]) {
        [self.delegate sliderView:self switchingIndex:switchingIndex leavingIndex:leavingIndex percentage:percentage];
    }
}

-(void)tapMenuSwitchSelectIndex:(NSUInteger)selectIndex
{
    CGFloat rollLength = self.collectionView.bk_width * selectIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
    //即将离开代理
    if ([self.delegate respondsToSelector:@selector(sliderView:willLeaveIndex:)]) {
        [self.delegate sliderView:self willLeaveIndex:self.selectIndex];
    }
    //离开中代理
    if ([self.delegate respondsToSelector:@selector(sliderView:switchingIndex:leavingIndex:percentage:)]) {
        [self.delegate sliderView:self switchingIndex:selectIndex leavingIndex:self.selectIndex percentage:1];
    }
    //已经离开
    [self switchSelectIndex:selectIndex];
}

-(void)refreshMenuUI:(BKSliderMenuView*)menuView
{
    if ([self.delegate respondsToSelector:@selector(sliderView:refreshMenuUI:)]) {
        [self.delegate sliderView:self refreshMenuUI:menuView];
    }
}

#pragma mark - 内容视图

-(NSMutableArray *)existingViewControllers
{
    if (!_existingViewControllers) {
        _existingViewControllers = [NSMutableArray array];
    }
    return _existingViewControllers;
}

-(UICollectionView*)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.menuView.frame), self.contentView.bk_width, self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame)) collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSliderViewCellID];
    }
    return _collectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewControllers count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSliderViewCellID forIndexPath:indexPath];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIViewController * vc = self.viewControllers[indexPath.item];
    vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell addSubview:vc.view];
    
    if (![self.existingViewControllers containsObject:vc.title]) {
        [self.existingViewControllers addObject:vc.title];
        if ([self.delegate respondsToSelector:@selector(sliderView:firstDisplayViewController:index:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate sliderView:self firstDisplayViewController:vc index:indexPath.item];
            });
        }
    }
    
    [self changeBgScrollContentSizeWithNowIndex:indexPath.item isScrollEnd:NO];
}

#pragma mark - 切换index

-(void)switchSelectIndex:(NSUInteger)selectIndex
{
    self.leaveIndex = self.selectIndex;
    self.selectIndex = selectIndex;
    
    if ([self.delegate respondsToSelector:@selector(sliderView:switchIndex:leaveIndex:)]) {
        [self.delegate sliderView:self switchIndex:self.selectIndex leaveIndex:self.leaveIndex];
    }
    [self changeBgScrollContentSizeWithNowIndex:_selectIndex isScrollEnd:YES];
}

#pragma mark - UIScrollDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if ([self.delegate respondsToSelector:@selector(sliderView:willLeaveIndex:)]) {
            [self.delegate sliderView:self willLeaveIndex:self.selectIndex];
        }
        
    }else if (scrollView == self.bgScrollView) {
        
        self.bgScrollViewIsScrolling = YES;
        
        [self changeBgScrollContentSizeWithNowIndex:self.selectIndex isScrollEnd:YES];
        
        if ([self.delegate respondsToSelector:@selector(sliderView:willBeginDraggingBgScrollView:)]) {
            [self.delegate sliderView:self willBeginDraggingBgScrollView:self.bgScrollView];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if (self.menuView.isTapMenuSwitchingIndex) {
            return;
        }
        [self.menuView scrollCollectionView:self.collectionView];

    }else if (scrollView == self.bgScrollView) {
        
        if ([self.delegate respondsToSelector:@selector(sliderView:didScrollBgScrollView:)]) {
            [self.delegate sliderView:self didScrollBgScrollView:self.bgScrollView];
        }
        
        if (self.headerView) {
            UIScrollView * scrollView = [self getFrontScrollViewWithNowIndex:self.selectIndex];
            
            CGFloat contentOffSetY = self.bgScrollView.contentOffset.y;
            if (contentOffSetY > self.headerView.bk_height) {
                self.contentView.bk_y = contentOffSetY;
                if (scrollView) {
                    scrollView.contentOffset = CGPointMake(0, contentOffSetY - self.headerView.bk_height);
                }
            }else {
                self.contentView.bk_y = CGRectGetMaxY(self.headerView.frame);
                if (scrollView) {
                    scrollView.contentOffset = CGPointZero;
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.bgScrollView) {
        
        if (!decelerate) {
            self.bgScrollViewIsScrolling = NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(sliderView:didEndDraggingBgScrollView:willDecelerate:)]) {
            [self.delegate sliderView:self didEndDraggingBgScrollView:_bgScrollView willDecelerate:decelerate];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        
        if (self.menuView.isTapMenuSwitchingIndex) {
            return;
        }

        CGPoint convertPoint = CGPointMake(self.collectionView.bk_centerX, self.menuView.bk_height + self.collectionView.bk_height/2);
        CGPoint point = [self.contentView convertPoint:convertPoint toView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
        NSInteger item = indexPath.item;
        
        self.menuView.selectIndex = item;
        
        [self switchSelectIndex:item];
        
    }else if (scrollView == _bgScrollView) {
        
        self.bgScrollViewIsScrolling = NO;
        
        if ([_delegate respondsToSelector:@selector(sliderView:didEndDeceleratingBgScrollView:)]) {
            [_delegate sliderView:self didEndDeceleratingBgScrollView:_bgScrollView];
        }
    }
}

#pragma mark - UIPanGestureRecognizer

-(void)setUseCsPanGestureOnCollectionView:(BOOL)useCsPanGestureOnCollectionView
{
    _useCsPanGestureOnCollectionView = useCsPanGestureOnCollectionView;
    if (useCsPanGestureOnCollectionView) {
        self.collectionView.scrollEnabled = NO;
        [self.collectionView addGestureRecognizer:self.csCollectionViewPanGesture];
    }else {
        self.collectionView.scrollEnabled = YES;
        [self.collectionView removeGestureRecognizer:self.csCollectionViewPanGesture];
        self.csCollectionViewPanGesture = nil;
    }
}

-(UIPanGestureRecognizer *)csCollectionViewPanGesture
{
    if (!_csCollectionViewPanGesture) {
        _csCollectionViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(csCollectionViewPanGesture:)];
        _csCollectionViewPanGesture.delegate = self;
    }
    return _csCollectionViewPanGesture;
}

-(void)setCsCollectionViewPanGesture:(UIPanGestureRecognizer *)csCollectionViewPanGesture
{
    _csCollectionViewPanGesture = csCollectionViewPanGesture;
}

-(void)csCollectionViewPanGesture:(UIPanGestureRecognizer*)panGesture
{
    if (!panGesture.enabled) {
        return;
    }
    
    UICollectionView * collectionView = (UICollectionView*)panGesture.view;
    CGPoint tPoint = [panGesture translationInView:collectionView];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [[collectionView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.userInteractionEnabled = NO;
            }];
            [self scrollViewWillBeginDragging:collectionView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat contentOffsetX = collectionView.contentOffset.x - tPoint.x;
            if (contentOffsetX < 0) {
                contentOffsetX = 0;
            }else if (contentOffsetX > collectionView.contentSize.width - collectionView.bk_width) {
                contentOffsetX = collectionView.contentSize.width - collectionView.bk_width;
            }
            [collectionView setContentOffset:CGPointMake(contentOffsetX, collectionView.contentOffset.y)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            NSInteger item;
            if (velocity.x > 500) {
                item = collectionView.contentOffset.x / collectionView.bk_width - 1;
            }else if (velocity.x < -500) {
                item = collectionView.contentOffset.x / collectionView.bk_width + 1;
            }else {
                item = round(collectionView.contentOffset.x / collectionView.bk_width);
            }
            CGFloat contentOffsetX = item * collectionView.bk_width;
            [collectionView setContentOffset:CGPointMake(contentOffsetX, collectionView.contentOffset.y) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.csCollectionViewPanGesture.state == UIGestureRecognizerStateEnded || self.csCollectionViewPanGesture.state == UIGestureRecognizerStateCancelled ||
                    self.csCollectionViewPanGesture.state == UIGestureRecognizerStateFailed ||
                    self.csCollectionViewPanGesture.state == UIGestureRecognizerStatePossible) {
                    [[collectionView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.userInteractionEnabled = YES;
                    }];
                    [self scrollViewDidEndDecelerating:collectionView];
                }
            });
        }
            break;
        default:
            break;
    }
    
    [panGesture setTranslation:CGPointZero inView:collectionView];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (!self.bgScrollViewIsScrolling && self.csCollectionViewPanGesture == gestureRecognizer) {
        //如果collectionView滑动中禁止其他所有手势
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
            return NO;
        }
        UIPanGestureRecognizer * panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint tPoint = [panGesture translationInView:panGesture.view];
        if (fabs(tPoint.x) > fabs(tPoint.y)) {
            UICollectionView * collectionView = (UICollectionView*)panGesture.view;
            CGFloat contentOffsetX = collectionView.contentOffset.x - tPoint.x;
            if (contentOffsetX >= 0 && contentOffsetX <= collectionView.contentSize.width - collectionView.bk_width) {
                return NO;
            }
        }
    }
    
    self.csCollectionViewPanGesture.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.csCollectionViewPanGesture.enabled = YES;
    });
    
    return YES;
}


@end
