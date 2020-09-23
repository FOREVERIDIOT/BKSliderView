//
//  BKPageControlView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKPageControlView.h"
#import "BKPCVBgScrollView.h"
#import "UIViewController+BKPageControlView.h"
#import "UIView+BKPageControlView.h"

NSString * const kBKPageControlViewCellID = @"kBKPageControlViewCellID";

@interface BKPageControlView() <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BKPageControlMenuViewDelegate>

/// 内容视图是否正在滚动中
@property (nonatomic,assign) BOOL collectionViewIsScrolling;
/// 引起的内容视图动画滚动
@property (nonatomic,assign) BOOL collectionViewAnimateScrolling;

/// 子视图数组 当未创建子视图时用@""代替
@property (nonatomic,strong) NSMutableArray * childControllers;

@end

@implementation BKPageControlView
@synthesize superVC = _superVC;
@synthesize displayVC = _displayVC;

-(NSMutableArray *)childControllers
{
    if (!_childControllers) {
        _childControllers = [NSMutableArray array];
    }
    return _childControllers;
}

#pragma mark - 索引

-(void)setDisplayIndex:(NSUInteger)displayIndex
{
    if (_displayIndex == displayIndex) {
        return;
    }else if (displayIndex > [self.menuTitles count] - 1) {
        _displayIndex = [self.menuTitles count] - 1;
    }else {
        _displayIndex = displayIndex;
    }
    
    if (self.menuView.selectIndex != _displayIndex) {
        self.menuView.selectIndex = _displayIndex;
    }
    
    CGFloat rollLength = self.collectionView.width * _displayIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(nullable void (^)(void))animated completion:(nullable void(^)(void))completion
{
    if (_displayIndex == displayIndex) {
        return;
    }else if (displayIndex > [self.menuTitles count] - 1) {
        _displayIndex = [self.menuTitles count] - 1;
    }else {
        _displayIndex = displayIndex;
    }
    
    self.collectionViewAnimateScrolling = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.menuView setSelectIndex:_displayIndex animated:^{
        CGFloat rollLength = weakSelf.collectionView.width *    weakSelf.displayIndex;
        [weakSelf.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:YES];
        
        if (animated) {
            animated();
        }
    } completion:^{
        if (weakSelf.collectionViewAnimateScrolling) {
            weakSelf.collectionViewAnimateScrolling = NO;
            if (completion) {
                completion();
            }
        }
    }];
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

-(void)setMenuTitles:(NSArray<NSString *> *)menuTitles
{
    _menuTitles = menuTitles;
    
    [self removeChildViewKVOForItem:self.displayIndex atCell:nil];
    [self setBgScrollViewScrollToTop];
    [self.childControllers removeAllObjects];
    
    for (NSString * title in _menuTitles) {
        NSUInteger existCount = 0;
        for (NSString * t in _menuTitles) {
            if ([t isEqualToString:title]) {
                existCount++;
            }
        }
        NSAssert(existCount == 1, @"标题不能重复添加");
        [self.childControllers addObject:@""];
    }
    [self.collectionView reloadData];
    
    self.menuView.titles = [_menuTitles copy];
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
    return [self initWithFrame:frame superVC:superVC menuTitles:nil];
}

-(instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC menuTitles:(NSArray<NSString *> *)menuTitles
{
    return [self initWithFrame:frame superVC:superVC menuTitles:nil delegate:nil];
}

-(instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC menuTitles:(NSArray<NSString *> *)menuTitles delegate:(id<BKPageControlViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.superVC = superVC;
        self.menuTitles = menuTitles;
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

-(BKPageControlBgScrollView*)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[BKPageControlBgScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _bgScrollView.delegate = self;
    }
    return _bgScrollView;
}

/// 设置主视图滚动到最顶部
-(void)setBgScrollViewScrollToTop
{
    self.bgScrollView.contentOffset = CGPointZero;
    
    for (UIViewController * vc in self.childControllers) {
        if ([vc isKindOfClass:[UIViewController class]]) {
            for (UIView * view in [vc.view subviews]) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    ((UIScrollView*)view).contentOffset = CGPointZero;
                }
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
            UIScrollView * scrollView = [self getMainScrollViewWithCorrespondingIndex:index];
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

/// 获取对应索引视图内的scrollView
/// @param index 索引
-(nullable UIScrollView*)getMainScrollViewWithCorrespondingIndex:(NSInteger)index
{
    if ([self.childControllers count] > index) {
        id obj = self.childControllers[index];
        if (obj) {
            UIViewController * vc = (UIViewController*)obj;
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

-(BKPageControlMenuView*)menuView
{
    if (!_menuView) {
        _menuView = [[BKPageControlMenuView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 45)];
        _menuView.delegate = self;
        _menuView.pageControlView = self;
    }
    return _menuView;
}

#pragma mark - BKPageControlMenuViewDelegate

-(void)changeMenuViewFrame
{
    self.collectionView.y = CGRectGetMaxY(self.menuView.frame);
    self.collectionView.height = self.contentView.height - CGRectGetMaxY(self.menuView.frame);
    [self.collectionView reloadData];
}

-(void)menuView:(nonnull BKPageControlMenuView*)menuView willLeaveIndex:(NSUInteger)leaveIndex
{
    if ([self.delegate respondsToSelector:@selector(pageControlView:willLeaveIndex:)]) {
        [self.delegate pageControlView:self willLeaveIndex:leaveIndex];
    }
}

-(void)menuView:(BKPageControlMenuView*)menuView switchingSelectIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
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

-(void)menuView:(BKPageControlMenuView*)menuView switchIndex:(NSUInteger)switchIndex
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

-(UICollectionView*)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.menuView.frame), self.contentView.width, self.contentView.height - CGRectGetMaxY(self.menuView.frame)) collectionViewLayout:layout];
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
        id obj = self.childControllers[indexPath.item];
        BOOL isVC = [obj isKindOfClass:[UIViewController class]];
        if ((self.collectionViewAnimateScrolling && (isVC || self.displayIndex == indexPath.item)) ||
            !self.collectionViewAnimateScrolling) {
            UIViewController * vc = nil;
            if (isVC) {
                vc = (UIViewController*)obj;
            }else {
                vc = [self.delegate pageControlView:self initializeIndex:indexPath.item];
                [self.childControllers replaceObjectAtIndex:indexPath.item withObject:vc];
            }
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
        id obj = self.childControllers[item];
        if ([obj isKindOfClass:[UIViewController class]]) {
            UIViewController * vc = (UIViewController*)obj;
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

        [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willBeginDraggingBgScrollView:)]) {
            [self.delegate pageControlView:self willBeginDraggingBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_willBeginDraggingSuperBgScrollView:)]) {
            [(UIView<BKPCVBgScrollView>*)self.displayVC bk_willBeginDraggingSuperBgScrollView:self.bgScrollView];
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
            [(UIView<BKPCVBgScrollView>*)self.displayVC bk_didScrollSuperBgScrollView:self.bgScrollView];
        }
        
        if (self.headerView || self.superLevelPageControlView) {
            UIScrollView * scrollView = [self getMainScrollViewWithCorrespondingIndex:self.displayIndex];
            
            CGFloat contentOffsetY = self.bgScrollView.contentOffset.y;
            if (contentOffsetY > self.headerView.height) {
                self.contentView.y = contentOffsetY;
                if (scrollView) {
                    scrollView.contentOffset = CGPointMake(0, contentOffsetY - self.headerView.height);
                }
            }else {
                self.contentView.y = CGRectGetMaxY(self.headerView.frame);
                if (scrollView) {
                    scrollView.contentOffset = CGPointZero;
                }
            }
        }
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.bgScrollView) {

        if ([self.delegate respondsToSelector:@selector(pageControlView:willEndDraggingBgScrollView:withVelocity:targetContentOffset:)]) {
            [self.delegate pageControlView:self willEndDraggingBgScrollView:self.bgScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_willEndDraggingSuperBgScrollView:withVelocity:targetContentOffset:)]) {
            [(UIView<BKPCVBgScrollView>*)self.displayVC bk_willEndDraggingSuperBgScrollView:self.bgScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
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
            [(UIView<BKPCVBgScrollView>*)self.displayVC bk_didEndDraggingSuperBgScrollView:self.bgScrollView willDecelerate:decelerate];
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
            [(UIView<BKPCVBgScrollView>*)self.displayVC bk_didEndDeceleratingSuperBgScrollView:self.bgScrollView];
        }
    }
}

@end
