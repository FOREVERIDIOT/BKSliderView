//
//  BKPageControlView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKPageControlView.h"
#import "BKPageControlScrollViewProtocol.h"
#import "UIViewController+BKPageControlView.h"
#import "UIView+BKPageControlView.h"

NSString * const kBKPageControlViewCellID = @"kBKPageControlViewCellID";

@interface BKPageControlView() <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BKPageControlDelegate>

/// 竖向滚动视图是否在拖拽中
@property (nonatomic,assign) BOOL bgScrollViewIsDragging;

/// 内容视图是否正在滚动中
@property (nonatomic,assign) BOOL collectionViewIsScrolling;
/// 引起的内容视图动画滚动
@property (nonatomic,assign) BOOL collectionViewAnimateScrolling;

@end

@implementation BKPageControlView
@synthesize superVC = _superVC;
@synthesize displayIndex = _displayIndex;
@synthesize displayVC = _displayVC;

#pragma mark - 索引

-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(BOOL)animated
{
    [self setDisplayIndex:displayIndex animated:animated completion:nil];
}

-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(BOOL)animated completion:(nullable void(^)(void))completion
{
    [self setDisplayIndex:displayIndex animation:^BOOL{
        return animated;
    } completion:completion];
}

-(void)setDisplayIndex:(NSUInteger)displayIndex animation:(nullable BOOL(^)(void))animation completion:(nullable void(^)(void))completion
{
    if (_displayIndex == displayIndex) {
        return;
    }else if (displayIndex > [self.childControllers count] - 1) {
        _displayIndex = [self.childControllers count] - 1;
    }else {
        _displayIndex = displayIndex;
    }
    
    if (animation && animation()) {
        self.collectionViewAnimateScrolling = YES;
        
        __weak typeof(self) weakSelf = self;
        [self.menuView setSelectIndex:_displayIndex animated:^{
            CGFloat rollLength = weakSelf.collectionView.width * weakSelf.displayIndex;
            [weakSelf.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:YES];
            
            if (animation) {
                animation();
            }
        } completion:^{
            if (weakSelf.collectionViewAnimateScrolling) {
                weakSelf.collectionViewAnimateScrolling = NO;
                if (completion) {
                    completion();
                }
            }
        }];
    }else {
        if (self.menuView.selectIndex != _displayIndex) {
            self.menuView.selectIndex = _displayIndex;
        }
        
        CGFloat rollLength = self.collectionView.width * _displayIndex;
        [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
        
        if (completion) {
            completion();
        }
    }
}

-(UIViewController *)displayVC
{
    return [self getViewControllerAtIndex:self.displayIndex];
}

/// 获取对应索引的视图
-(UIViewController*)getViewControllerAtIndex:(NSUInteger)index
{
    if ([self.childControllers count] > index) {
        id obj = self.childControllers[index];
        if ([obj isKindOfClass:[UIViewController class]]) {
            return obj;
        }
    }
    return nil;
}

#pragma mark - 详情内容视图左右插入量

-(void)setContentLrInsets:(CGFloat)contentLrInsets
{
    _contentLrInsets = contentLrInsets;
    [self layoutSubviews];
}

#pragma mark - BKPageControlView嵌套

-(void)setSuperLevelPageControlView:(BKPageControlView *)superLevelPageControlView
{
    _superLevelPageControlView = superLevelPageControlView;
    if (_superLevelPageControlView) {
        self.bgScrollView.scrollEnabled = NO;
    }else {
        self.bgScrollView.scrollEnabled = YES;
    }
}

#pragma mark - init

-(void)setChildControllers:(NSArray<UIViewController *> *)childControllers
{
    [self setBgScrollViewScrollToTop];
    
    _childControllers = childControllers;
    
    NSMutableArray * titles = [NSMutableArray array];
    for (UIViewController * childVC in _childControllers) {
        NSAssert([childVC isKindOfClass:[UIViewController class]], @"子控制器不正确");
        NSAssert([childVC.title isKindOfClass:[NSString class]], @"标题格式不正确");
        NSAssert([childVC.title length] > 0, @"标题不能为空");
        NSUInteger existCount = 0;
        for (UIViewController * t in _childControllers) {
            if ([t.title isEqualToString:childVC.title]) {
                existCount++;
            }
        }
        NSAssert(existCount == 1, @"标题不能重复添加");
        [titles addObject:childVC.title];
    }
    [self.collectionView reloadData];
    
    self.menuView.titles = [titles copy];
}

-(void)setSuperVC:(UIViewController *)superVC
{
    _superVC = superVC;
    NSAssert([_superVC isKindOfClass:[UIViewController class]], @"父控制器设置错误");
}

-(UIViewController*)superVC
{
    return _superVC;
}

-(instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC
{
    return [self initWithFrame:frame superVC:superVC childControllers:nil];
}

-(instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC childControllers:(nullable NSArray<UIViewController *> *)childControllers
{
    return [self initWithFrame:frame superVC:superVC childControllers:nil delegate:nil];
}

-(instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC childControllers:(nullable NSArray<UIViewController *> *)childControllers delegate:(nullable id<BKPageControlViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.superVC = superVC;
        self.childControllers = childControllers;
        self.delegate = delegate;
        
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
            self.contentView.frame = CGRectMake(0, 0, self.bgScrollView.width, self.bgScrollView.height);
        }else {
            if (self.bgScrollView.contentOffset.y > self.headerView.height) {
                self.contentView.frame = CGRectMake(0, self.bgScrollView.contentOffset.y, self.bgScrollView.width, self.bgScrollView.height);
            }else {
                self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.bgScrollView.width, self.bgScrollView.height);
            }
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgScrollView.frame = CGRectMake(0, 0, self.width, self.height);
    if (![[self.bgScrollView subviews] containsObject:self.headerView]) {
        self.contentView.frame = CGRectMake(0, 0, self.bgScrollView.width, self.bgScrollView.height);
    }else {
        if (self.bgScrollView.contentOffset.y > self.headerView.height) {
            self.contentView.frame = CGRectMake(0, self.bgScrollView.contentOffset.y, self.bgScrollView.width, self.bgScrollView.height);
        }else {
            self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.bgScrollView.width, self.bgScrollView.height);
        }
    }
    self.menuView.frame = CGRectMake(0, 0, self.contentView.width, self.menuView.height);
    
    CGRect lastCollectionViewRect = self.collectionView.frame;
    self.collectionView.frame = CGRectMake(self.contentLrInsets, CGRectGetMaxY(self.menuView.frame), self.contentView.width - self.contentLrInsets*2, self.contentView.height - CGRectGetMaxY(self.menuView.frame));
    if (!CGSizeEqualToSize(lastCollectionViewRect.size, self.collectionView.frame.size)) {
        [self.collectionView reloadData];
    }
    CGFloat rollLength = self.collectionView.width * self.displayIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

-(void)dealloc
{
    [self removeChildViewKVOForItem:self.displayIndex atCell:nil];
}

#pragma mark - 初始化UI

-(void)initUI
{
    [self addSubview:self.bgScrollView];
    [self.bgScrollView addSubview:self.contentView];
    [self.contentView addSubview:self.menuView];
    [self.contentView insertSubview:self.collectionView belowSubview:self.menuView];
}

#pragma mark - 主视图

-(BKPageControlScrollView*)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[BKPageControlScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _bgScrollView.delegate = self;
    }
    return _bgScrollView;
}

/// 设置主视图滚动到最顶部
-(void)setBgScrollViewScrollToTop
{
    self.bgScrollView.contentOffset = CGPointZero;
    
    for (UIViewController * vc in self.childControllers) {
        for (UIView * view in [vc.view subviews]) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView*)view).contentOffset = CGPointZero;
            }
        }
    }
}

#pragma mark - 第二级视图
#pragma mark - 头视图

-(void)setHeaderView:(UIView *)headerView
{
    if (_headerView != headerView) {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    _headerView = headerView;
    [self.bgScrollView addSubview:_headerView];
    self.contentView.y = CGRectGetMaxY(_headerView.frame);
    
    [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
}

/// 根据详情内容视图内容长度(比如UIScrollView的contentSize.height)改变主视图的contentSize.height
/// @param index 索引
-(void)changeBgScrollContentSizeWithNowIndex:(NSInteger)index
{
    //用线程使修改contentSize在滑动中生效
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.headerView || self.superLevelPageControlView) {
            //获取当前详情内容视图内的滚动视图
            UIScrollView * scrollView = [self getChildScrollViewAtIndex:index];
            //如果详情内容视图中包含滚动视图 禁止滚动视图滑动能力
            if (scrollView) {//有滚动视图
                //滚动视图禁止滑动
                scrollView.scrollEnabled = NO;
                //滚动视图的contentSize.height > 滚动视图自身height
                if (scrollView.contentSize.height > scrollView.height) {
                    //算出滚动式图在父视图上少的高度
                    CGFloat scrollView_top_bottom_supperH = self.displayVC.view.height - scrollView.height;
                    //所有内容高度 = 头视图高度 + 导航视图高度 + 滚动视图的内容高度 + 滚动视图顶部插入量 + 滚动视图底部插入量
                    CGFloat contentSizeHeight = self.headerView.height + self.menuView.height + scrollView_top_bottom_supperH + scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
                    //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
                    if (contentSizeHeight > self.bgScrollView.contentSize.height) {
                        self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
                    }
                    
                    if (self.bgScrollView.contentOffset.y < self.headerView.height) {
                        //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                        scrollView.contentOffset = CGPointZero;
                    }else {
                        //如果主视图滑动高度 > 头视图高度 根据滚动视图的滑动高度修改主视图滑动高度
                        if (index == self.displayIndex) {
                            self.bgScrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + self.headerView.height);
                            //修改主视图偏移量需要把内容视图的y值修改对应高度
                            if (self.bgScrollView.contentOffset.y > self.headerView.height) {
                                self.contentView.y = self.bgScrollView.contentOffset.y;
                            }else {
                                self.contentView.y = CGRectGetMaxY(self.headerView.frame);
                            }
                        }
                    }
                    //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
                    if (!self.collectionViewIsScrolling && contentSizeHeight != self.bgScrollView.contentSize.height) {
                        self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
                    }
                    return;
                }
            }
            
            /*
              以下是判断
             （有滚动视图 && 滚动视图的contentSize.height < 滚动视图自身height）|| 无滚动视图的情况
             */
            //所有内容高度 = 头视图高度 + 详情内容视图高度
            CGFloat contentSizeHeight = self.headerView.height + self.contentView.height;
            //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
            if (contentSizeHeight > self.bgScrollView.contentSize.height) {
                self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
            }
            
            if (self.bgScrollView.contentOffset.y < self.headerView.height) {
                //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                scrollView.contentOffset = CGPointZero;
            }else{
                //如果主视图滑动高度 > 头视图高度 修改主视图滑动高度
                if (index == self.displayIndex) {
                    self.bgScrollView.contentOffset = CGPointMake(0, self.headerView.height);
                    //修改主视图偏移量需要把内容视图的y值修改对应高度
                    self.contentView.y = CGRectGetMaxY(self.headerView.frame);
                }
            }
            //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
            if (!self.collectionViewIsScrolling && contentSizeHeight != self.bgScrollView.contentSize.height) {
                self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
            }
        }
    });
}

/// 获取对应索引子视图内的scrollView
/// @param index 索引
-(nullable UIScrollView*)getChildScrollViewAtIndex:(NSInteger)index
{
    if ([self.childControllers count] > index) {
        UIViewController * vc = self.childControllers[index];
        if (vc.bk_pcv_mainScrollView) {
            return vc.bk_pcv_mainScrollView;
        }
        [[vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIScrollView class]]) {
                vc.bk_pcv_mainScrollView = obj;
                *stop = YES;
            }else if ([obj isKindOfClass:[BKPageControlView class]]) {
                vc.bk_pcv_mainScrollView = ((BKPageControlView*)obj).bgScrollView;
                *stop = YES;
            }
        }];
        return vc.bk_pcv_mainScrollView;
    }
    return nil;
}

#pragma mark - 内容视图

-(UIView*)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bgScrollView.width, self.bgScrollView.height)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

#pragma mark - 第三级视图
#pragma mark - 导航视图

-(BKPageControl*)menuView
{
    if (!_menuView) {
        _menuView = [[BKPageControl alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 45)];
        _menuView.delegate = self;
        _menuView.pageControlView = self;
    }
    return _menuView;
}

#pragma mark - BKPageControlDelegate

-(void)changeMenuViewFrame
{
    self.collectionView.y = CGRectGetMaxY(self.menuView.frame);
    self.collectionView.height = self.contentView.height - CGRectGetMaxY(self.menuView.frame);
    [self.collectionView reloadData];
}

-(void)menuView:(nonnull BKPageControl*)menuView willLeaveIndex:(NSUInteger)leaveIndex
{
    if ([self.delegate respondsToSelector:@selector(pageControlView:willLeaveIndex:)]) {
        [self.delegate pageControlView:self willLeaveIndex:leaveIndex];
    }
}

-(void)menuView:(BKPageControl*)menuView switchingSelectIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
{
    if (switchingIndex > [self.childControllers count] - 1 ||
        switchingIndex < 0 ||
        leavingIndex > [self.childControllers count] - 1 ||
        leavingIndex < 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pageControlView:switchingIndex:leavingIndex:percentage:)]) {
        [self.delegate pageControlView:self switchingIndex:switchingIndex leavingIndex:leavingIndex percentage:percentage];
    }
}

-(void)menuView:(BKPageControl*)menuView switchIndex:(NSUInteger)switchIndex
{
    NSUInteger leaveIndex = self.displayIndex;
    __weak typeof(self) weakSelf = self;
    [self setDisplayIndex:switchIndex animated:nil completion:^{
        if ([weakSelf.delegate respondsToSelector:@selector(pageControlView:switchIndex:leaveIndex:)]) {
            [weakSelf.delegate pageControlView:weakSelf switchIndex:weakSelf.displayIndex leaveIndex:leaveIndex];
        }
        [weakSelf changeBgScrollContentSizeWithNowIndex:weakSelf.displayIndex];
    }];
}

-(void)menu:(BKPageControlMenu*)menu atIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(pageControlView:menu:atIndex:)]) {
        [self.delegate pageControlView:self menu:menu atIndex:index];
    }
}

#pragma mark - 内容视图

-(BKPageControlCollectionView*)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[BKPageControlCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.menuView.frame), self.contentView.width, self.contentView.height - CGRectGetMaxY(self.menuView.frame)) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBKPageControlViewCellID];
    }
    return _collectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.childControllers count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBKPageControlViewCellID forIndexPath:indexPath];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < [self.childControllers count]) {
        UIViewController * vc = self.childControllers[indexPath.item];
        if ((self.collectionViewAnimateScrolling && (vc.isViewLoaded || self.displayIndex == indexPath.item)) ||
            !self.collectionViewAnimateScrolling) {
            vc.bk_pcv_index = indexPath.item;
            vc.bk_pcv_pageControlView = self;
            [self.superVC addChildViewController:vc];
            vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:vc.view];
            [vc didMoveToParentViewController:self.superVC];
            
            [self changeBgScrollContentSizeWithNowIndex:indexPath.item];
            
            [vc addObserver:self forKeyPath:@"bk_pcv_mainScrollView" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(@(indexPath.item))];
            [vc addObserver:self forKeyPath:@"bk_pcv_mainScrollView.contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(@(indexPath.item))];
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeChildViewKVOForItem:indexPath.item atCell:cell];
}

#pragma mark - KVO

/// 删除对应索引的kvo
-(void)removeChildViewKVOForItem:(NSUInteger)item atCell:(nullable UICollectionViewCell*)cell
{
    if (item < [self.childControllers count]) {
        UIViewController * vc = self.childControllers[item];
        if (vc.isViewLoaded) {
            [vc removeObserver:self forKeyPath:@"bk_pcv_mainScrollView" context:(__bridge void * _Nullable)(@(item))];
            [vc removeObserver:self forKeyPath:@"bk_pcv_mainScrollView.contentSize" context:(__bridge void * _Nullable)(@(item))];
            [vc willMoveToParentViewController:nil];
            [vc removeFromParentViewController];
        }
    }
    if (cell) {
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bk_pcv_mainScrollView"]) {
        NSUInteger item = [(__bridge id)context integerValue];
        if (item == self.displayIndex) {
            [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
        }
    }else if ([keyPath isEqualToString:@"bk_pcv_mainScrollView.contentSize"]) {
        NSValue * o = change[@"old"];
        CGSize o_size = CGSizeZero;
        if (![o isKindOfClass:[NSNull class]] && o != nil) {
            o_size = [o CGSizeValue];
        }
        NSValue * n = change[@"new"];
        CGSize n_size = CGSizeZero;
        if (![n isKindOfClass:[NSNull class]] && n != nil) {
            n_size = [n CGSizeValue];
        }
        if (!CGSizeEqualToSize(o_size, n_size)) {
            NSUInteger item = [(__bridge id)context integerValue];
            if (item == self.displayIndex) {
                [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
            }
        }
    }
}

#pragma mark - UIScrollDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        self.collectionViewIsScrolling = YES;
        self.collectionViewAnimateScrolling = NO;
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willLeaveIndex:)]) {
            [self.delegate pageControlView:self willLeaveIndex:self.displayIndex];
        }
    }else if (scrollView == self.bgScrollView) {
        
        self.bgScrollViewIsDragging = YES;

        [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willBeginDraggingBgScrollView:)]) {
            [self.delegate pageControlView:self willBeginDraggingBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_willBeginDraggingSuperBgScrollView:)]) {
            [(UIViewController<BKPageControlScrollViewProtocol>*)self.displayVC bk_willBeginDraggingSuperBgScrollView:self.bgScrollView];
        }
        
        UIScrollView * childScrollView = [self getChildScrollViewAtIndex:self.displayIndex];
        if (childScrollView) {
            //配合mjRefresh不足一屏加载的判断 添加手势状态
            childScrollView.panGestureRecognizer.state = UIGestureRecognizerStateBegan;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if (self.collectionViewAnimateScrolling) {
            return;
        }
        
        [self.menuView collectionViewDidScroll:self.collectionView];
        
    }else if (scrollView == self.bgScrollView) {

        if ([self.delegate respondsToSelector:@selector(pageControlView:didScrollBgScrollView:)]) {
            [self.delegate pageControlView:self didScrollBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_didScrollSuperBgScrollView:)]) {
            [(UIViewController<BKPageControlScrollViewProtocol>*)self.displayVC bk_didScrollSuperBgScrollView:self.bgScrollView];
        }
        
        UIScrollView * childScrollView = [self getChildScrollViewAtIndex:self.displayIndex];
        if (childScrollView) {
            CGFloat contentOffsetY = self.bgScrollView.contentOffset.y;
            if (contentOffsetY > self.headerView.height) {
                self.contentView.y = contentOffsetY;
                childScrollView.contentOffset = CGPointMake(0, contentOffsetY - self.headerView.height);
            }else {
                self.contentView.y = CGRectGetMaxY(self.headerView.frame);
                childScrollView.contentOffset = CGPointZero;
            }
            
            if (self.bgScrollViewIsDragging) {
                //配合mjRefresh不足一屏加载的判断 添加手势状态
                childScrollView.panGestureRecognizer.state = UIGestureRecognizerStateChanged;
            }
        }
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.bgScrollView) {
        
        self.bgScrollViewIsDragging = NO;

        if ([self.delegate respondsToSelector:@selector(pageControlView:willEndDraggingBgScrollView:withVelocity:targetContentOffset:)]) {
            [self.delegate pageControlView:self willEndDraggingBgScrollView:self.bgScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_willEndDraggingSuperBgScrollView:withVelocity:targetContentOffset:)]) {
            [(UIViewController<BKPageControlScrollViewProtocol>*)self.displayVC bk_willEndDraggingSuperBgScrollView:self.bgScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }
        
        UIScrollView * childScrollView = [self getChildScrollViewAtIndex:self.displayIndex];
        if (childScrollView && (*targetContentOffset).y >= self.headerView.height) {
            //配合mjRefresh不足一屏加载的判断 添加手势状态
            childScrollView.panGestureRecognizer.state = UIGestureRecognizerStateEnded;
        }else {
            childScrollView.panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.collectionView) {
        if (!decelerate) {
            self.collectionViewIsScrolling = NO;
        }
    }else if (scrollView == self.bgScrollView) {

        if ([self.delegate respondsToSelector:@selector(pageControlView:didEndDraggingBgScrollView:willDecelerate:)]) {
            [self.delegate pageControlView:self didEndDraggingBgScrollView:self.bgScrollView willDecelerate:decelerate];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_didEndDraggingSuperBgScrollView:willDecelerate:)]) {
            [(UIViewController<BKPageControlScrollViewProtocol>*)self.displayVC bk_didEndDraggingSuperBgScrollView:self.bgScrollView willDecelerate:decelerate];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        self.collectionViewIsScrolling = NO;
        if (self.collectionViewAnimateScrolling) {
            return;
        }
        
        [self.menuView collectionViewDidEndDecelerating:self.collectionView];
        
    }else if (scrollView == self.bgScrollView) {

        if ([self.delegate respondsToSelector:@selector(pageControlView:didEndDeceleratingBgScrollView:)]) {
            [self.delegate pageControlView:self didEndDeceleratingBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_didEndDeceleratingSuperBgScrollView:)]) {
            [(UIViewController<BKPageControlScrollViewProtocol>*)self.displayVC bk_didEndDeceleratingSuperBgScrollView:self.bgScrollView];
        }
    }
}

@end
