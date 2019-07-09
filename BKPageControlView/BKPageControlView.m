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
#import "BKPageControlKVOModel.h"

NSString * const kBKPageControlViewCellID = @"kBKPageControlViewCellID";

@interface BKPageControlView()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BKPageControlMenuViewDelegate,UIGestureRecognizerDelegate>

/**
 子控制器kvo数组
 */
@property (nonatomic,strong) NSMutableArray<BKPageControlKVOModel*> * subControllersKvos;

/**
 离开的index
 */
@property (nonatomic,assign) NSInteger leaveIndex;

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
@property (nonatomic,strong) NSTimer * panGestureTimer;

/**
 是否需要重新计算主滚动视图的偏移量Y 仅bgScrollViewScrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView有效
 */
@property (nonatomic,assign) BOOL isNeedReCalcBgScrollViewContentOffsetY;

@end

@implementation BKPageControlView
@synthesize csCollectionViewPanGesture = _csCollectionViewPanGesture;
@synthesize superVC = _superVC;
@synthesize displayVC = _displayVC;

#pragma mark - 展示的vc数组

-(void)setChildControllers:(NSArray<UIViewController<BKPageControlViewController> *> *)childControllers
{
    _childControllers = childControllers;
    
    [self.superVC.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(BKPageControlViewController)]) {
            [obj willMoveToParentViewController:nil];
            [obj removeFromParentViewController];
        }
    }];
    
    NSMutableArray * titles = [NSMutableArray array];
    for (int i = 0; i < [_childControllers count]; i++) {
        UIViewController<BKPageControlViewController> * vc = _childControllers[i];
        NSAssert([vc conformsToProtocol:@protocol(BKPageControlViewController)], @"控制器必须遵循BKPageControlViewController代理");
        vc.bk_index = i;
        vc.bk_superVC = self.superVC;
        NSAssert(vc.title != nil, @"未创建标题");
        NSUInteger existCount = 0;
        for (UIViewController * vc2 in _childControllers) {
            if (vc == vc2) {
                existCount++;
            }
        }
        NSAssert(existCount == 1, @"已添加控制器不能重复添加");
        [titles addObject:vc.title];
    }
    [self.collectionView reloadData];
    self.menuView.titles = [titles copy];
}

#pragma mark - 索引

-(void)setDisplayIndex:(NSUInteger)displayIndex
{
    if (displayIndex > [self.childControllers count] - 1) {
        _displayIndex = [self.childControllers count] - 1;
    }else {
        _displayIndex = displayIndex;
    }
    self.menuView.selectIndex = _displayIndex;
}

-(UIViewController<BKPageControlViewController> *)displayVC
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
    for (int i = 0; i < [self.childControllers count]; i++) {
        UIViewController<BKPageControlViewController> * vc = self.childControllers[i];
        vc.bk_superVC = _superVC;
    }
}

-(UIViewController*)superVC
{
    return _superVC;
}

#pragma mark - init

-(nonnull instancetype)initWithFrame:(CGRect)frame childControllers:(nullable NSArray<UIViewController<BKPageControlViewController>*>*)childControllers superVC:(nonnull UIViewController*)superVC
{
    return [self initWithFrame:frame delegate:nil childControllers:childControllers superVC:superVC];
}

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BKPageControlViewDelegate>)delegate childControllers:(NSArray<UIViewController<BKPageControlViewController> *> *)childControllers superVC:(UIViewController *)superVC
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.childControllers = childControllers;
        self.superVC = superVC;
        
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
    //检测collectionView的宽度是否为0
    BOOL collectionViewWIsZero = self.collectionView.bk_width == 0 ? YES : NO;
    self.collectionView.frame = CGRectMake(self.contentLrInsets, CGRectGetMaxY(self.menuView.frame), self.contentView.bk_width - self.contentLrInsets*2, self.contentView.bk_height - CGRectGetMaxY(self.menuView.frame));
    //若果为0 是因为创建时frame赋值为CGRectZero了 在此判断一下如果宽为0 选中的index不为0 改变contentOffSet
    if (collectionViewWIsZero && self.displayIndex != 0) {
        CGFloat rollLength = self.collectionView.bk_width * self.displayIndex;
        [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
    }
}

-(void)dealloc
{
    [self.subControllersKvos enumerateObjectsUsingBlock:^(BKPageControlKVOModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSString * keyPath in obj.kvoKeyPaths) {
            [obj.childController removeObserver:self forKeyPath:keyPath];
        }
        obj.childController = nil;
        obj.kvoKeyPaths = nil;
    }];
    [self.subControllersKvos removeAllObjects];
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
    
    [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
}

/**
 根据详情内容视图内容长度(比如UIScrollView的contentSize.height)改变主视图的contentSize.height
 
 @param index 第几页
 */
-(void)changeBgScrollContentSizeWithNowIndex:(NSInteger)index
{
    if (_headerView) {
        //获取当前详情内容视图内的滚动视图
        UIScrollView * scrollView = [self getFrontScrollViewWithNowIndex:index];
        //如果详情内容视图中包含滚动视图 禁止滚动视图滑动能力
        if (scrollView) {//有滚动视图
            scrollView.scrollEnabled = NO;
            //滚动视图的contentSize.height > 滚动视图自身height
            if (scrollView.contentSize.height > scrollView.bk_height) {
                //算出滚动式图在父视图上少的高度
                CGFloat scrollView_top_bottom_supperH = [scrollView superview].bk_height - scrollView.bk_height;
                //所有内容高度 = 头视图高度 + 导航视图高度 + 滚动视图的内容高度
                CGFloat contentSizeHeight = self.headerView.bk_height + self.menuView.bk_height + scrollView_top_bottom_supperH + scrollView.contentSize.height;
                //当 所有内容高度 > 当前主视图内容高度 时 修改主视图内容高度
                if (contentSizeHeight > self.bgScrollView.contentSize.height) {
                    self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.bk_width, contentSizeHeight);
                }
                
                if (self.bgScrollView.contentOffset.y < self.headerView.bk_height) {
                    if (self.bgScrollViewScrollOrder != BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                        //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                        scrollView.contentOffset = CGPointZero;
                    }
                }else {
                    //如果主视图滑动高度 > 头视图高度 根据滚动视图的滑动高度修改主视图滑动高度
                    if (index == self.displayIndex) {
                        self.bgScrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + self.headerView.bk_height);
                    }
                }
                //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
                if (!self.collectionViewIsScrolling && contentSizeHeight != self.bgScrollView.contentSize.height) {
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
            if (self.bgScrollViewScrollOrder != BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                //如果主视图滑动高度 < 头视图高度 修改主视图滑动高度为0
                scrollView.contentOffset = CGPointZero;
            }
        }else{
            //如果主视图滑动高度 > 头视图高度 修改主视图滑动高度
            if (index == self.displayIndex) {
                self.bgScrollView.contentOffset = CGPointMake(0, self.headerView.bk_height);
            }
        }
        //如果停止详情内容视图横向滑动 && 所有内容高度 != 当前主视图内容高度 时 修改主视图内容高度
        if (!self.collectionViewIsScrolling && contentSizeHeight != self.bgScrollView.contentSize.height) {
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
    UIViewController<BKPageControlViewController> * vc = self.childControllers[index];
    if (!vc.bk_mainScrollView) {
        [[vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIScrollView class]]) {
                vc.bk_mainScrollView = obj;
                *stop = YES;
            }else if ([obj isKindOfClass:[BKPageControlView class]]) {
                vc.bk_mainScrollView = ((BKPageControlView*)obj).bgScrollView;
                *stop = YES;
            }
        }];
    }
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

-(void)switchingSelectIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
{
    if (switchingIndex > [self.childControllers count] - 1 || switchingIndex < 0 || leavingIndex > [self.childControllers count] - 1 || leavingIndex < 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pageControlView:switchingIndex:leavingIndex:percentage:)]) {
        [self.delegate pageControlView:self switchingIndex:switchingIndex leavingIndex:leavingIndex percentage:percentage];
    }
}

-(void)tapMenuSwitchSelectIndex:(NSUInteger)selectIndex
{
    CGFloat rollLength = self.collectionView.bk_width * selectIndex;
    [self.collectionView setContentOffset:CGPointMake(rollLength, 0) animated:NO];
    //即将离开代理
    if ([self.delegate respondsToSelector:@selector(pageControlView:willLeaveIndex:)]) {
        [self.delegate pageControlView:self willLeaveIndex:self.displayIndex];
    }
    //离开中代理
    if ([self.delegate respondsToSelector:@selector(pageControlView:switchingIndex:leavingIndex:percentage:)]) {
        [self.delegate pageControlView:self switchingIndex:selectIndex leavingIndex:self.displayIndex percentage:1];
    }
    //已经离开
    [self switchDisplayIndex:selectIndex];
}

-(void)menu:(BKPageControlMenu*)menu settingIconImageView:(UIImageView*)iconImageView selectIconImageView:(UIImageView*)selectIconImageView atIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(pageControlView:menu:settingIconImageView:selectIconImageView:atIndex:)]) {
        [self.delegate pageControlView:self menu:menu settingIconImageView:iconImageView selectIconImageView:selectIconImageView atIndex:index];
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
    UIViewController<BKPageControlViewController> * vc = self.childControllers[indexPath.item];
    vc.view.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell addSubview:vc.view];
    [self.superVC addChildViewController:vc];
    [vc didMoveToParentViewController:self.superVC];
    
    [self changeBgScrollContentSizeWithNowIndex:indexPath.item];
    
    BKPageControlKVOModel * kvoModel = [self getCurrentChildControllerKvoModelWithController:vc];
    NSMutableArray * kvoKeyPaths = [NSMutableArray array];
    [vc addObserver:self forKeyPath:@"bk_mainScrollView" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [kvoKeyPaths addObject:@"bk_mainScrollView"];
    if (vc.bk_mainScrollView) {
        [vc addObserver:self forKeyPath:@"bk_mainScrollView.contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [kvoKeyPaths addObject:@"bk_mainScrollView.contentSize"];
    }
    kvoModel.kvoKeyPaths = [kvoKeyPaths copy];
    [self.subControllersKvos addObject:kvoModel];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController<BKPageControlViewController> * vc = self.childControllers[indexPath.item];
    [self removeCurrentChildControllerKvoModelWithController:vc];
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - 切换index

-(void)switchDisplayIndex:(NSUInteger)displayIndex
{
    self.leaveIndex = self.displayIndex;
    self.displayIndex = displayIndex;
    
    if ([self.delegate respondsToSelector:@selector(pageControlView:switchIndex:leaveIndex:)]) {
        [self.delegate pageControlView:self switchIndex:self.displayIndex leaveIndex:self.leaveIndex];
    }
    [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
}

#pragma mark - subControllersKvos

-(NSMutableArray<BKPageControlKVOModel *> *)subControllersKvos
{
    if (!_subControllersKvos) {
        _subControllersKvos = [NSMutableArray array];
    }
    return _subControllersKvos;
}

/**
 获取对应控制器的kvoModel
 */
-(BKPageControlKVOModel*)getCurrentChildControllerKvoModelWithController:(UIViewController*)controller
{
    __block BKPageControlKVOModel * kvoModel = nil;
    [self.subControllersKvos enumerateObjectsUsingBlock:^(BKPageControlKVOModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.childController == controller) {
            kvoModel = obj;
            *stop = YES;
        }
    }];
    if (!kvoModel) {
        kvoModel = [[BKPageControlKVOModel alloc] init];
        kvoModel.childController = controller;
    }else {
        [kvoModel.kvoKeyPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [kvoModel.childController removeObserver:self forKeyPath:obj];
        }];
        kvoModel.childController = nil;
        kvoModel.kvoKeyPaths = nil;
    }
    return kvoModel;
}

/**
 删除对应控制器的kvoModel
 */
-(void)removeCurrentChildControllerKvoModelWithController:(UIViewController*)controller
{
    BKPageControlKVOModel * kvoModel = [self getCurrentChildControllerKvoModelWithController:controller];
    if (kvoModel) {
        [kvoModel.kvoKeyPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [kvoModel.childController removeObserver:self forKeyPath:obj];
        }];
        kvoModel.childController = nil;
        kvoModel.kvoKeyPaths = nil;
        [self.subControllersKvos removeObject:kvoModel];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bk_mainScrollView"]) {
        UIScrollView * o = change[@"old"];
        UIScrollView * n = change[@"new"];
        if (o != n) {
            dispatch_async(dispatch_get_main_queue(), ^{//用线程使修改contentSize在滑动中生效
                [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
            });
        }
    }else if ([keyPath isEqualToString:@"bk_mainScrollView.contentSize"]) {
        CGSize o = [change[@"old"] CGSizeValue];
        CGSize n = [change[@"new"] CGSizeValue];
        if (!CGSizeEqualToSize(o, n)) {
            dispatch_async(dispatch_get_main_queue(), ^{//用线程使修改contentSize在滑动中生效
                [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
            });
        }
    }
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
        self.bgScrollViewIsScrolling = YES;
        
        [self changeBgScrollContentSizeWithNowIndex:self.displayIndex];
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:willBeginDraggingBgScrollView:)]) {
            [self.delegate pageControlView:self willBeginDraggingBgScrollView:self.bgScrollView];
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
        if ([self.delegate respondsToSelector:@selector(pageControlView:didScrollBgScrollView:)]) {
            [self.delegate pageControlView:self didScrollBgScrollView:self.bgScrollView];
        }
        
        if (self.headerView) {
            UIScrollView * scrollView = [self getFrontScrollViewWithNowIndex:self.displayIndex];
            
            CGFloat contentOffsetY = self.bgScrollView.contentOffset.y;
            if (contentOffsetY > self.headerView.bk_height) {
                self.contentView.bk_y = contentOffsetY;
                if (scrollView) {
                    if (self.bgScrollViewScrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
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
                if (self.bgScrollViewScrollOrder == BKPageControlBgScrollViewScrollOrderFirstScrollContentView) {
                    if (scrollView) {
                        //在此处不需要重新计算主滚动视图的偏移量Y 但是得需要计算一下子控制器中的主滚动视图的偏移量Y 所以用isNeedReCalcBgScrollViewContentOffsetY这个参数替代判断了
                        if (self.isNeedReCalcBgScrollViewContentOffsetY) {
                            //当主滚动式图的偏移量Y小于0 && 子控制器中的主滚动视图的偏移量Y大于0 需把偏移量Y传递
                            if (self.bgScrollView.contentOffset.y < 0) {
                                if (scrollView.contentOffset.y > 0) {
                                    //主滚动式图的偏移量Y小于0时 滑动速度会因scrollView橡皮筋效果影响 因此给主滚动视图添加一个top插入量
                                    self.bgScrollView.contentInset = UIEdgeInsetsMake(self.bk_height, 0, 0, 0);
                                    CGFloat calc_contentOffsetY = scrollView.contentOffset.y + contentOffsetY;
                                    scrollView.contentOffset = CGPointMake(0, calc_contentOffsetY < 0 ? 0 : calc_contentOffsetY);
                                    self.bgScrollView.contentOffset = CGPointZero;
                                }else {
                                    //当主滚动式图的偏移量Y小于0 && 子控制器中的主滚动视图的偏移量Y小于0 把插入量归0
                                    self.bgScrollView.contentInset = UIEdgeInsetsZero;
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

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.collectionView) {
        if (!decelerate) {
            self.collectionViewIsScrolling = NO;
        }
    }else if (scrollView == self.bgScrollView) {
        if (!decelerate) {
            self.bgScrollViewIsScrolling = NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(pageControlView:didEndDraggingBgScrollView:willDecelerate:)]) {
            [self.delegate pageControlView:self didEndDraggingBgScrollView:_bgScrollView willDecelerate:decelerate];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        self.collectionViewIsScrolling = NO;
        
        if (self.menuView.isTapMenuSwitchingIndex) {
            return;
        }

        CGPoint convertPoint = CGPointMake(self.contentLrInsets + self.collectionView.bk_centerX, self.menuView.bk_height + self.collectionView.bk_height/2);
        CGPoint point = [self.contentView convertPoint:convertPoint toView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
        NSInteger item = indexPath.item;
        
        self.menuView.selectIndex = item;
        
        [self switchDisplayIndex:item];
        
    }else if (scrollView == _bgScrollView) {
        self.bgScrollViewIsScrolling = NO;
        
        if ([_delegate respondsToSelector:@selector(pageControlView:didEndDeceleratingBgScrollView:)]) {
            [_delegate pageControlView:self didEndDeceleratingBgScrollView:_bgScrollView];
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
            [self.panGestureTimer invalidate];
            self.panGestureTimer = nil;
            
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
        case UIGestureRecognizerStatePossible:
        {
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            NSInteger item;
            if (velocity.x > 0) {
                item = ceil(collectionView.contentOffset.x / collectionView.bk_width - 1);
            }else if (velocity.x < 0) {
                item = floor(collectionView.contentOffset.x / collectionView.bk_width + 1);
            }else {
                item = round(collectionView.contentOffset.x / collectionView.bk_width);
            }
            if (item < 0) {
                item = 0;
            }else if (item > [self.childControllers count] - 1) {
                item = [self.childControllers count] - 1;
            }
            CGFloat contentOffsetX = item * collectionView.bk_width;
            [collectionView setContentOffset:CGPointMake(contentOffsetX, collectionView.contentOffset.y) animated:YES];
            
            self.panGestureTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(panGestureTimerMethod) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.panGestureTimer forMode:NSRunLoopCommonModes];
        }
            break;
        default:
            break;
    }
    
    [panGesture setTranslation:CGPointZero inView:collectionView];
}

-(void)panGestureTimerMethod
{
    [[self.collectionView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
    }];
    [self scrollViewDidEndDecelerating:self.collectionView];
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
