//
//  BKSlideView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#import "BKSlideView.h"
#import "UIView+BKSlideView.h"
#import "objc/runtime.h"

NSString * const kSliderViewCellID = @"kSliderViewCellID";

@interface BKSlideView()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/**
 已经存在的vc
 */
@property (nonatomic,strong) NSMutableArray * existingViewControllers;

/**
 离开的index
 */
@property (nonatomic,assign) NSInteger leaveIndex;

/**
 是否点击menu
 */
@property (nonatomic,assign) BOOL isTapMenu;

@end

@implementation BKSlideView

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

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BKSlideViewDelegate>)delegate viewControllers:(NSArray *)viewControllers
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
            self.contentView.frame = self.bgScrollView.bounds;
        }else {
            self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.bgScrollView.bk_width, self.bgScrollView.bk_height);
        }
    }
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
        _bgScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
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
 @param isScrollEnd slideView是否滑动结束
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
        _contentView = [[UIView alloc] initWithFrame:self.bgScrollView.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

#pragma mark - 第三级视图
#pragma mark - 导航视图

-(BKSlideMenuView*)menuView
{
    if (!_menuView) {
        _menuView = [[BKSlideMenuView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bk_width, 45)];
        __weak typeof(self) weakSelf = self;
        [_menuView setChangeMenuViewFrameCallBack:^{
            [weakSelf changeMenuViewFrame];
        }];
        [_menuView setSwitchSelectIndexCallBack:^(NSUInteger selectIndex) {
            [weakSelf tapMenuSwitchSelectIndex:selectIndex];
        }];
        [_menuView setSwitchSelectIndexCompleteCallBack:^{
            weakSelf.isTapMenu = NO;
        }];
    }
    return _menuView;
}

-(void)changeMenuViewFrame
{
    self.collectionView.bk_y = CGRectGetMaxY(self.menuView.frame);
    self.collectionView.bk_height = self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame);
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(slideViewDidChangeFrame:)]) {
        [self.delegate slideViewDidChangeFrame:self];
    }
}

-(void)tapMenuSwitchSelectIndex:(NSUInteger)selectIndex
{
    if (self.isTapMenu) {
        return;
    }
    self.isTapMenu = YES;
    
    CGFloat rollLength = self.collectionView.bk_width * selectIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(slideView:leaveIndex:)]) {
        [self.delegate slideView:self leaveIndex:self.selectIndex];
    }
    
    [self switchSelectIndex:selectIndex];
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
        layout.itemSize = CGSizeMake(self.contentView.bk_width, self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame));
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
    
    if ([self.delegate respondsToSelector:@selector(slideView:createViewControllerWithIndex:)]) {
        if (![self.existingViewControllers containsObject:vc.title]) {
            [self.existingViewControllers addObject:vc.title];
            [self.delegate slideView:self createViewControllerWithIndex:indexPath.item];
        }
    }
    
    [self changeBgScrollContentSizeWithNowIndex:indexPath.item isScrollEnd:NO];
}

#pragma mark - 切换index

-(void)switchSelectIndex:(NSUInteger)selectIndex
{
    self.leaveIndex = self.selectIndex;
    self.selectIndex = selectIndex;
    
    if ([self.delegate respondsToSelector:@selector(slideView:switchIndex:leaveIndex:)]) {
        [self.delegate slideView:self switchIndex:self.selectIndex leaveIndex:self.leaveIndex];
    }
    [self changeBgScrollContentSizeWithNowIndex:_selectIndex isScrollEnd:YES];
}

#pragma mark - UIScrollDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if ([self.delegate respondsToSelector:@selector(slideView:leaveIndex:)]) {
            [self.delegate slideView:self leaveIndex:self.selectIndex];
        }
        
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    }else if (scrollView == self.bgScrollView) {
        [self changeBgScrollContentSizeWithNowIndex:self.selectIndex isScrollEnd:YES];
        
        if ([self.delegate respondsToSelector:@selector(slideView:willBeginDraggingBgScrollView:)]) {
            [self.delegate slideView:self willBeginDraggingBgScrollView:self.bgScrollView];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if (self.isTapMenu) {
            return;
        }
        [self.menuView scrollCollectionView:self.collectionView];

    }else if (scrollView == self.bgScrollView) {
        
        if ([self.delegate respondsToSelector:@selector(slideView:didScrollBgScrollView:)]) {
            [self.delegate slideView:self didScrollBgScrollView:self.bgScrollView];
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.collectionView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        });
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if (scrollView == self.collectionView) {
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        }
    }
    
    if (scrollView == self.bgScrollView) {
        if ([self.delegate respondsToSelector:@selector(slideView:didEndDraggingBgScrollView:willDecelerate:)]) {
            [self.delegate slideView:self didEndDraggingBgScrollView:_bgScrollView willDecelerate:decelerate];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        if (self.isTapMenu) {
            return;
        }

        CGPoint convertPoint = CGPointMake(self.collectionView.bk_centerX, self.menuView.bk_height + self.collectionView.bk_height/2);
        CGPoint point = [self.contentView convertPoint:convertPoint toView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
        NSInteger item = indexPath.item;
        
        self.menuView.selectIndex = item;
        
        [self switchSelectIndex:item];
        
    }else if (scrollView == _bgScrollView) {
        if ([_delegate respondsToSelector:@selector(slideView:didEndDeceleratingBgScrollView:)]) {
            [_delegate slideView:self didEndDeceleratingBgScrollView:_bgScrollView];
        }
    }
}



@end
