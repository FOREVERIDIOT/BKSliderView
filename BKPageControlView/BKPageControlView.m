//
//  BKPageControlView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#import "BKPageControlView.h"
#import "UIView+BKPageControlView.h"
#import "BKPCViewKVOChildControllerPModel.h"

NSString * const kBKPageControlViewCellID = @"kBKPageControlViewCellID";

@interface BKPageControlView()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BKPageControlMenuViewDelegate>
//UIGestureRecognizerDelegate

/**
 KVO监听子控制器中的属性数组
 */
@property (nonatomic,strong) NSMutableArray<BKPCViewKVOChildControllerPModel*> * kvoModels;

/**
 主视图是否正在滚动中
 */
@property (nonatomic,assign) BOOL bgScrollViewIsScrolling;
/**
 内容视图是否正在滚动中
 */
@property (nonatomic,assign) BOOL collectionViewIsScrolling;

/**
 panGesture定时器
 */
@property (nonatomic,strong) NSTimer * panGestureTimer DEPRECATED_MSG_ATTRIBUTE("废弃了 已经用alwaysBounceHorizontal=NO + [super setContentOffset:CGPointMake(0, contentOffset.y)];实现需求效果了");

@end

@implementation BKPageControlView
//@synthesize csCollectionViewPanGesture = _csCollectionViewPanGesture;
@synthesize superVC = _superVC;
@synthesize displayVC = _displayVC;

#pragma mark - KVO监听子控制器中的属性数组

-(NSMutableArray<BKPCViewKVOChildControllerPModel *> *)kvoModels
{//为啥要用这个数组监听 是因为直接监听数组中的对象的属性大部分没有走回调方法
    if (!_kvoModels) {
        _kvoModels = [NSMutableArray array];
    }
    return _kvoModels;
}

#pragma mark - 展示的vc数组

-(void)setChildControllers:(NSArray<UIViewController *> *)childControllers
{
    _childControllers = childControllers;
    
    [self.superVC.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj willMoveToParentViewController:nil];
        [obj removeFromParentViewController];
    }];
    [self.kvoModels removeAllObjects];
    
    NSMutableArray * titles = [NSMutableArray array];
    for (int i = 0; i < [_childControllers count]; i++) {
        UIViewController * vc = _childControllers[i];
        vc.bk_index = i;
        vc.bk_pageControlView = self;
        vc.bk_isFollowSuperScrollViewScrollDown = YES;
        NSAssert(vc.title != nil, @"未创建标题");
        NSUInteger existCount = 0;
        for (UIViewController * vc2 in _childControllers) {
            if (vc == vc2) {
                existCount++;
            }
        }
        NSAssert(existCount == 1, @"已添加控制器不能重复添加");
        [titles addObject:vc.title];
        
        BKPCViewKVOChildControllerPModel * kvoModel = [[BKPCViewKVOChildControllerPModel alloc] initWithChildController:vc];
        [self.kvoModels addObject:kvoModel];
    }
    [self.collectionView reloadData];
    self.menuView.titles = [titles copy];
}

#pragma mark - 索引

-(void)setDisplayIndex:(NSUInteger)displayIndex
{
    if (_displayIndex == displayIndex) {
        return;
    }else if (displayIndex > [self.childControllers count] - 1) {
        _displayIndex = [self.childControllers count] - 1;
    }else {
        _displayIndex = displayIndex;
    }
    
    if (self.menuView.selectIndex != _displayIndex) {
        self.menuView.selectIndex = _displayIndex;
    }
    
    CGFloat rollLength = self.collectionView.bk_width * _displayIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

-(void)setDisplayIndex:(NSUInteger)displayIndex animated:(nullable void (^)(void))animated completion:(nullable void(^)(void))completion
{
    if (_displayIndex == displayIndex) {
        return;
    }else if (displayIndex > [self.childControllers count] - 1) {
        _displayIndex = [self.childControllers count] - 1;
    }else {
        _displayIndex = displayIndex;
    }
    
    if (self.menuView.selectIndex != _displayIndex) {
        [self.menuView setSelectIndex:_displayIndex animated:^{
            if (animated) {
                animated();
            }
        } completion:^{
            if (completion) {
                completion();
            }
        }];
    }
    
    CGFloat rollLength = self.collectionView.bk_width * _displayIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

-(UIViewController *)displayVC
{
    return self.childControllers[self.displayIndex];
}

#pragma mark - 详情内容视图左右插入量

-(void)setContentLrInsets:(CGFloat)contentLrInsets
{
    _contentLrInsets = contentLrInsets;
    [self layoutSubviews];
}

#pragma mark - 父控制器

-(void)setSuperVC:(UIViewController *)superVC
{
    _superVC = superVC;
}

-(UIViewController*)superVC
{
    return _superVC;
}

#pragma mark - init

-(nonnull instancetype)initWithFrame:(CGRect)frame childControllers:(nullable NSArray<UIViewController *> *)childControllers superVC:(nonnull UIViewController *)superVC
{
    return [self initWithFrame:frame delegate:nil childControllers:childControllers superVC:superVC];
}

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BKPageControlViewDelegate>)delegate childControllers:(nullable NSArray<UIViewController *> *)childControllers superVC:(nonnull UIViewController *)superVC
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.childControllers = childControllers;
        self.superVC = superVC;
        
        [self initUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMainScrollViewNotification:) name:kBKPCViewChangeMainScrollViewNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMainScrollViewContentSizeNotification:) name:kBKPCViewChangeMainScrollViewContentSizeNotification object:nil];
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
    
    CGRect lastCollectionViewRect = self.collectionView.frame;
    self.collectionView.frame = CGRectMake(self.contentLrInsets, CGRectGetMaxY(self.menuView.frame), self.contentView.bk_width - self.contentLrInsets*2, self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame));
    if (!CGSizeEqualToSize(lastCollectionViewRect.size, self.collectionView.frame.size)) {
        [self.collectionView reloadData];
    }
    CGFloat rollLength = self.collectionView.bk_width * self.displayIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBKPCViewChangeMainScrollViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBKPCViewChangeMainScrollViewContentSizeNotification object:nil];
}

#pragma mark - 通知

-(void)changeMainScrollViewNotification:(NSNotification*)notification
{
    NSUInteger correspondingIndex = [notification.userInfo[@"bk_index"] integerValue];
    if (correspondingIndex == self.displayIndex) {
        [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
    }
}

-(void)changeMainScrollViewContentSizeNotification:(NSNotification*)notification
{
    NSUInteger correspondingIndex = [notification.userInfo[@"bk_index"] integerValue];
    if (correspondingIndex == self.displayIndex) {
        [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
    }
}

#pragma mark - 初始化UI

-(void)initUI
{
    [self addSubview:self.bgScrollView];
    [self.bgScrollView addSubview:self.contentView];
    [self.contentView addSubview:self.menuView];
    [self.contentView insertSubview:self.collectionView belowSubview:self.menuView];
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

#pragma mark - 主视图

-(BKPageControlBgScrollView*)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[BKPageControlBgScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bk_width, self.bk_height)];
        _bgScrollView.delegate = self;
    }
    return _bgScrollView;
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
    self.contentView.bk_y = CGRectGetMaxY(_headerView.frame);
    
    [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
}

/**
 根据详情内容视图内容长度(比如UIScrollView的contentSize.height)改变主视图的contentSize.height
 
 @param index 第几页
 */
-(void)changeBgScrollContentSizeWithNowIndex:(NSInteger)index
{
    //用线程使修改contentSize在滑动中生效
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.headerView || self.superLevelPageControlView) {
            //获取当前详情内容视图内的滚动视图
            UIScrollView * scrollView = [self getMainScrollViewWithCorrespondingIndex:index];
            //如果详情内容视图中包含滚动视图 禁止滚动视图滑动能力
            if (scrollView) {//有滚动视图
                UIViewController * displayVC = self.childControllers[index];
                //判断主滚动视图允不允许滑动
                if (displayVC.bk_MSVScrollEnable) {
                    scrollView.scrollEnabled = YES;
                    return;
                }else {
                    scrollView.scrollEnabled = NO;
                }
                //滚动视图的contentSize.height > 滚动视图自身height
                if (scrollView.contentSize.height > scrollView.bk_height) {
                    //算出滚动式图在父视图上少的高度
                    CGFloat scrollView_top_bottom_supperH = self.displayVC.view.bk_height - scrollView.bk_height;
                    //所有内容高度 = 头视图高度 + 导航视图高度 + 滚动视图的内容高度
                    CGFloat contentSizeHeight = self.headerView.bk_height + self.menuView.bk_height + scrollView_top_bottom_supperH + scrollView.contentSize.height;
                    //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
                    if (contentSizeHeight > self.bgScrollView.contentSize.height) {
                        self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
                    }
                    
                    if (self.bgScrollView.contentOffset.y < self.headerView.bk_height) {
                        if (self.bgScrollView.scrollOrder != BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                            //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                            scrollView.contentOffset = CGPointZero;
                        }
                    }else {
                        //如果主视图滑动高度 > 头视图高度 根据滚动视图的滑动高度修改主视图滑动高度
                        if (index == self.displayIndex) {
                            self.bgScrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + self.headerView.bk_height);
                            //修改主视图偏移量需要把内容视图的y值修改对应高度
                            if (self.bgScrollView.contentOffset.y > self.headerView.bk_height) {
                                self.contentView.bk_y = self.bgScrollView.contentOffset.y;
                            }else {
                                self.contentView.bk_y = CGRectGetMaxY(self.headerView.frame);
                            }
                        }
                    }
                    //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
                    if (!self.collectionViewIsScrolling && contentSizeHeight != self.bgScrollView.contentSize.height) {
                        self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
                    }
                    return;
                }
            }else {
                UIViewController * displayVC = self.childControllers[index];
                //判断主滚动视图允不允许滑动
                if (displayVC.bk_MSVScrollEnable) {
                    return;//不允许滑动return
                }
            }
            //有滚动视图 || 滚动视图的contentSize.height < 滚动视图自身height
            //所有内容高度 = 头视图高度 + 详情内容视图高度
            CGFloat contentSizeHeight = self.headerView.bk_height + self.contentView.bk_height;
            //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
            if (contentSizeHeight > self.bgScrollView.contentSize.height) {
                self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
            }
            
            if (self.bgScrollView.contentOffset.y < self.headerView.bk_height) {
                if (self.bgScrollView.scrollOrder != BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                    //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                    scrollView.contentOffset = CGPointZero;
                }
            }else{
                //如果主视图滑动高度 > 头视图高度 修改主视图滑动高度
                if (index == self.displayIndex) {
                    self.bgScrollView.contentOffset = CGPointMake(0, self.headerView.bk_height);
                    //修改主视图偏移量需要把内容视图的y值修改对应高度
                    self.contentView.bk_y = CGRectGetMaxY(self.headerView.frame);
                }
            }
            //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
            if (!self.collectionViewIsScrolling && contentSizeHeight != self.bgScrollView.contentSize.height) {
                self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.contentSize.width, contentSizeHeight);
            }
        }
    });
}

/**
 获取内容视图内的scrollview
 
 @return 内容视图内的scrollview
 */
-(UIScrollView*)getMainScrollViewWithCorrespondingIndex:(NSInteger)index
{
    UIViewController * vc = self.childControllers[index];
    if (vc.bk_mainScrollView) {
        return vc.bk_mainScrollView;
    }
    [[vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            vc.bk_mainScrollView = obj;
            *stop = YES;
        }else if ([obj isKindOfClass:[BKPageControlView class]]) {
            vc.bk_mainScrollView = ((BKPageControlView*)obj).bgScrollView;
            *stop = YES;
        }
    }];
    return vc.bk_mainScrollView;
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

-(BKPageControlMenuView*)menuView
{
    if (!_menuView) {
        _menuView = [[BKPageControlMenuView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bk_width, 45)];
        _menuView.delegate = self;
        _menuView.pageControlView = self;
    }
    return _menuView;
}

#pragma mark - BKPageControlMenuViewDelegate

-(void)changeMenuViewFrame
{
    self.collectionView.bk_y = CGRectGetMaxY(self.menuView.frame);
    self.collectionView.bk_height = self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame);
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
    if (switchingIndex > [self.childControllers count] - 1 || switchingIndex < 0 || leavingIndex > [self.childControllers count] - 1 || leavingIndex < 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pageControlView:switchingIndex:leavingIndex:percentage:)]) {
        [self.delegate pageControlView:self switchingIndex:switchingIndex leavingIndex:leavingIndex percentage:percentage];
    }
}

-(void)menuView:(BKPageControlMenuView*)menuView switchIndex:(NSUInteger)switchIndex
{
    NSUInteger leaveIndex = self.displayIndex;
    self.displayIndex = switchIndex;
    
    self.bgScrollView.scrollEnabled = !self.displayVC.bk_MSVScrollEnable;
    
    if ([self.delegate respondsToSelector:@selector(pageControlView:switchIndex:leaveIndex:)]) {
        [self.delegate pageControlView:self switchIndex:self.displayIndex leaveIndex:leaveIndex];
    }
    [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
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
    UIViewController * vc = self.childControllers[indexPath.item];
    vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell addSubview:vc.view];
    [self.superVC addChildViewController:vc];
    [vc didMoveToParentViewController:self.superVC];
    
    [self changeBgScrollContentSizeWithNowIndex:indexPath.item];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * vc = self.childControllers[indexPath.item];
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - UIScrollDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        self.collectionViewIsScrolling = YES;
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willLeaveIndex:)]) {
            [self.delegate pageControlView:self willLeaveIndex:self.displayIndex];
        }
    }else if (scrollView == self.bgScrollView) {
        if (self.displayVC.bk_MSVScrollEnable) {
            return;
        }
        
        self.bgScrollViewIsScrolling = YES;
        
        [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willBeginDraggingBgScrollView:)]) {
            [self.delegate pageControlView:self willBeginDraggingBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_willBeginDraggingSuperBgScrollView:)]) {
            [(UIViewController<BKPageControlViewController>*)self.displayVC bk_willBeginDraggingSuperBgScrollView:self.bgScrollView];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        
        [self.menuView collectionViewDidScroll:self.collectionView];
        
    }else if (scrollView == self.bgScrollView) {
        if (self.displayVC.bk_MSVScrollEnable) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:didScrollBgScrollView:)]) {
            [self.delegate pageControlView:self didScrollBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_didScrollSuperBgScrollView:)]) {
            [(UIViewController<BKPageControlViewController>*)self.displayVC bk_didScrollSuperBgScrollView:self.bgScrollView];
        }
        
        if (self.headerView || self.superLevelPageControlView) {
            UIScrollView * scrollView = [self getMainScrollViewWithCorrespondingIndex:self.displayIndex];
            
            CGFloat contentOffsetY = self.bgScrollView.contentOffset.y;
            if (contentOffsetY > self.headerView.bk_height) {
                self.contentView.bk_y = contentOffsetY;
                if (scrollView) {
                    if (self.bgScrollView.scrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                        //如果需要重新计算主滚动视图的偏移量Y
                        if (self.isNeedReCalcBgScrollViewContentOffsetY) {
                            self.isNeedReCalcBgScrollViewContentOffsetY = NO;
                            CGFloat calc_contentOffsetY = self.headerView.bk_height + scrollView.contentOffset.y;
                            CGFloat max_contentOffsetY = self.bgScrollView.contentSize.height - self.bgScrollView.bk_height;
                            calc_contentOffsetY = calc_contentOffsetY > max_contentOffsetY ? max_contentOffsetY : calc_contentOffsetY;
                            if (self.bgScrollView.contentOffset.y < calc_contentOffsetY) {
                                self.bgScrollView.contentOffset = CGPointMake(0, calc_contentOffsetY);
                                return;
                            }
                        }
                    }
                    scrollView.contentOffset = CGPointMake(0, contentOffsetY - self.headerView.bk_height);
                }
            }else {
                self.contentView.bk_y = CGRectGetMaxY(self.headerView.frame);
                if (self.bgScrollView.scrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                    if (scrollView) {
                        //在此处不需要重新计算主滚动视图的偏移量Y 但是得需要计算一下子控制器中的主滚动视图的偏移量Y 所以用isNeedReCalcBgScrollViewContentOffsetY这个参数替代判断了
                        if (self.isNeedReCalcBgScrollViewContentOffsetY) {
                            //当主滚动式图的偏移量Y小于0(有contentInset时应为-contentInset.top) && 子控制器中的主滚动视图的偏移量Y大于0 需把偏移量Y传递
                            if (self.bgScrollView.contentOffset.y < -self.bgScrollView.interiorContentInsets.top) {
                                if (scrollView.contentOffset.y > 0) {
                                    if ([self.displayVC respondsToSelector:@selector(setBk_isFollowSuperScrollViewScrollDown:)]) {
                                        if (!self.displayVC.bk_isFollowSuperScrollViewScrollDown) {
                                            return;
                                        }
                                    }
                                    //主滚动式图的偏移量Y小于0(有contentInset时应为-contentInset.top)时 滑动速度会因scrollView橡皮筋效果影响 因此给主滚动视图添加一个top插入量
                                    self.bgScrollView.interiorAddContentInsets = UIEdgeInsetsMake(self.bk_height, 0, 0, 0);
                                    //真正的偏移量 当有contentInset时 contentOffsetY会偏移个self.bgScrollView.contentInset.top
                                    CGFloat r_contentOffsetY = contentOffsetY + self.bgScrollView.interiorContentInsets.top;
                                    CGFloat calc_contentOffsetY = scrollView.contentOffset.y + r_contentOffsetY;
                                    scrollView.contentOffset = CGPointMake(0, calc_contentOffsetY < 0 ? 0 : calc_contentOffsetY);
                                    self.bgScrollView.contentOffset = CGPointMake(0, -self.bgScrollView.interiorContentInsets.top);
                                }else {
                                    //当主滚动式图的偏移量Y小于0 && 子控制器中的主滚动视图的偏移量Y小于0 把插入量归0
                                    self.bgScrollView.interiorAddContentInsets = UIEdgeInsetsZero;
                                }
                            }
                        }else {
                            scrollView.contentOffset = CGPointZero;
                        }
                    }
                    self.isNeedReCalcBgScrollViewContentOffsetY = YES;
                }else {
                    if (scrollView) {
                        scrollView.contentOffset = CGPointZero;
                    }
                }
            }
        }
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.bgScrollView) {
        if (self.displayVC.bk_MSVScrollEnable) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willEndDraggingBgScrollView:withVelocity:targetContentOffset:)]) {
            [self.delegate pageControlView:self willEndDraggingBgScrollView:self.bgScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_willEndDraggingSuperBgScrollView:withVelocity:targetContentOffset:)]) {
            [(UIViewController<BKPageControlViewController>*)self.displayVC bk_willEndDraggingSuperBgScrollView:self.bgScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
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
        if (self.displayVC.bk_MSVScrollEnable) {
            return;
        }
        
        if (!decelerate) {
            self.bgScrollViewIsScrolling = NO;
            //当主滚动式图惯性结束后把插入量归0
            self.bgScrollView.interiorAddContentInsets = UIEdgeInsetsZero;
        }
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:didEndDraggingBgScrollView:willDecelerate:)]) {
            [self.delegate pageControlView:self didEndDraggingBgScrollView:self.bgScrollView willDecelerate:decelerate];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_didEndDraggingSuperBgScrollView:willDecelerate:)]) {
            [(UIViewController<BKPageControlViewController>*)self.displayVC bk_didEndDraggingSuperBgScrollView:self.bgScrollView willDecelerate:decelerate];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        self.collectionViewIsScrolling = NO;
        
        [self.menuView collectionViewDidEndDecelerating:self.collectionView];
        
    }else if (scrollView == self.bgScrollView) {
        if (self.displayVC.bk_MSVScrollEnable) {
            return;
        }
        
        self.bgScrollViewIsScrolling = NO;
        //当主滚动式图惯性结束后把插入量归0
        self.bgScrollView.interiorAddContentInsets = UIEdgeInsetsZero;
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:didEndDeceleratingBgScrollView:)]) {
            [self.delegate pageControlView:self didEndDeceleratingBgScrollView:self.bgScrollView];
        }
        
        if ([self.displayVC respondsToSelector:@selector(bk_didEndDeceleratingSuperBgScrollView:)]) {
            [(UIViewController<BKPageControlViewController>*)self.displayVC bk_didEndDeceleratingSuperBgScrollView:self.bgScrollView];
        }
    }
}

//#pragma mark - UIPanGestureRecognizer
//
//-(void)setUseCsPanGestureOnCollectionView:(BOOL)useCsPanGestureOnCollectionView
//{
//    _useCsPanGestureOnCollectionView = useCsPanGestureOnCollectionView;
//    if (useCsPanGestureOnCollectionView) {
//        self.collectionView.scrollEnabled = NO;
//        [self.collectionView addGestureRecognizer:self.csCollectionViewPanGesture];
//    }else {
//        self.collectionView.scrollEnabled = YES;
//        [self.collectionView removeGestureRecognizer:self.csCollectionViewPanGesture];
//        self.csCollectionViewPanGesture = nil;
//    }
//}
//
//-(UIPanGestureRecognizer *)csCollectionViewPanGesture
//{
//    if (!_csCollectionViewPanGesture) {
//        _csCollectionViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(csCollectionViewPanGesture:)];
//        _csCollectionViewPanGesture.delegate = self;
//    }
//    return _csCollectionViewPanGesture;
//}
//
//-(void)setCsCollectionViewPanGesture:(UIPanGestureRecognizer *)csCollectionViewPanGesture
//{
//    _csCollectionViewPanGesture = csCollectionViewPanGesture;
//}
//
//-(void)csCollectionViewPanGesture:(UIPanGestureRecognizer*)panGesture
//{
//    if (!panGesture.enabled) {
//        return;
//    }
//
//    UICollectionView * collectionView = (UICollectionView*)panGesture.view;
//    CGPoint tPoint = [panGesture translationInView:collectionView];
//    switch (panGesture.state) {
//        case UIGestureRecognizerStateBegan:
//        {
//            [self.panGestureTimer invalidate];
//            self.panGestureTimer = nil;
//
//            [[collectionView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                obj.userInteractionEnabled = NO;
//            }];
//
//            [self scrollViewWillBeginDragging:collectionView];
//        }
//            break;
//        case UIGestureRecognizerStateChanged:
//        {
//            CGFloat contentOffsetX = collectionView.contentOffset.x - tPoint.x;
//            if (contentOffsetX < 0) {
//                contentOffsetX = 0;
//            }else if (contentOffsetX > collectionView.contentSize.width - collectionView.bk_width) {
//                contentOffsetX = collectionView.contentSize.width - collectionView.bk_width;
//            }
//            [collectionView setContentOffset:CGPointMake(contentOffsetX, collectionView.contentOffset.y)];
//        }
//            break;
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//        case UIGestureRecognizerStateFailed:
//        case UIGestureRecognizerStatePossible:
//        {
//            CGPoint velocity = [panGesture velocityInView:panGesture.view];
//            NSInteger item;
//            if (velocity.x > 0) {
//                item = ceil(collectionView.contentOffset.x / collectionView.bk_width - 1);
//            }else if (velocity.x < 0) {
//                item = floor(collectionView.contentOffset.x / collectionView.bk_width + 1);
//            }else {
//                item = round(collectionView.contentOffset.x / collectionView.bk_width);
//            }
//            if (item < 0) {
//                item = 0;
//            }else if (item > [self.childControllers count] - 1) {
//                item = [self.childControllers count] - 1;
//            }
//            CGFloat contentOffsetX = item * collectionView.bk_width;
//            [collectionView setContentOffset:CGPointMake(contentOffsetX, collectionView.contentOffset.y) animated:YES];
//
//            self.panGestureTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(panGestureTimerMethod) userInfo:nil repeats:NO];
//            [[NSRunLoop mainRunLoop] addTimer:self.panGestureTimer forMode:NSRunLoopCommonModes];
//        }
//            break;
//        default:
//            break;
//    }
//
//    [panGesture setTranslation:CGPointZero inView:collectionView];
//}
//
//-(void)panGestureTimerMethod
//{
//    [[self.collectionView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.userInteractionEnabled = YES;
//    }];
//    [self scrollViewDidEndDecelerating:self.collectionView];
//}
//
//#pragma mark - UIGestureRecognizerDelegate
//
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if (!self.bgScrollViewIsScrolling && self.csCollectionViewPanGesture == gestureRecognizer) {
//        //如果collectionView滑动中禁止其他所有手势
//        if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
//            return NO;
//        }
//        UIPanGestureRecognizer * panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
//        CGPoint tPoint = [panGesture translationInView:panGesture.view];
//        if (fabs(tPoint.x) > fabs(tPoint.y)) {
//            UICollectionView * collectionView = (UICollectionView*)panGesture.view;
//            CGFloat contentOffsetX = collectionView.contentOffset.x - tPoint.x;
//            if (contentOffsetX >= 0 && contentOffsetX <= collectionView.contentSize.width - collectionView.bk_width) {
//                return NO;
//            }
//        }
//    }
//
//    self.csCollectionViewPanGesture.enabled = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.csCollectionViewPanGesture.enabled = YES;
//    });
//
//    return YES;
//}

@end
