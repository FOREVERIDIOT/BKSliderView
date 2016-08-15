//
//  BKSlideView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKSlideView.h"

@interface BKSlideView()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation BKSlideView
@synthesize slideView = _slideView;
@synthesize pageNum = _pageNum;

-(instancetype)initWithFrame:(CGRect)frame allPageNum:(NSInteger)pageNum delegate:(id<BKSlideViewDelegate>)customDelegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _pageNum = pageNum;
        _customDelegate = customDelegate;
        
        [self initSlideView];
    }
    
    return self;
}

-(void)initSlideView
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _slideView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
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
    return _pageNum;
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

#pragma mark - UIScrollDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _slideView) {
        if ([self.customDelegate respondsToSelector:@selector(scrollSlideView:)]) {
            [self.customDelegate scrollSlideView:_slideView];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _slideView) {
        if ([self.customDelegate respondsToSelector:@selector(endScrollSlideView:)]) {
            [self.customDelegate endScrollSlideView:_slideView];
        }
    }
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

@end
