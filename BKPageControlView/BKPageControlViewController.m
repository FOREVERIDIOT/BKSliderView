//
//  BKPageControlViewController.m
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2019/8/19.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPageControlViewController.h"

NSString * const kBKPCViewChangeMainScrollViewNotification = @"kBKPCViewChangeMainScrollViewNotification";
NSString * const kBKPCViewChangeMainScrollViewContentSizeNotification = @"kBKPCViewChangeMainScrollViewContentSizeNotification";

@interface BKPageControlViewController ()

@end

@implementation BKPageControlViewController

#pragma mark - bk_mainScrollView

-(void)setBk_mainScrollView:(UIScrollView *)bk_mainScrollView
{
    if (_bk_mainScrollView != bk_mainScrollView) {
        _bk_mainScrollView = bk_mainScrollView;
        [[NSNotificationCenter defaultCenter] postNotificationName:kBKPCViewChangeMainScrollViewNotification object:nil userInfo:@{@"bk_index" : @(self.bk_index), @"bk_mainScrollView" : _bk_mainScrollView ? _bk_mainScrollView : [NSNull null]}];
    }
}

#pragma mark - viewDidLoad

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bk_isFollowSuperScrollViewScrollDown = YES;
    
    [self addObserver:self forKeyPath:@"bk_mainScrollView.contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

-(void)dealloc
{
    if (self.bk_mainScrollView) {
        [self removeObserver:self forKeyPath:@"bk_mainScrollView.contentSize"];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bk_mainScrollView.contentSize"]) {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kBKPCViewChangeMainScrollViewContentSizeNotification object:nil userInfo:@{@"bk_index" : @(self.bk_index), @"bk_mainScrollView" : self.bk_mainScrollView ? self.bk_mainScrollView : [NSNull null]}];
        }
    }
}

#pragma mark - 滑动主视图

/**
 开始滑动主视图
 */
-(void)bk_willBeginDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView
{
    
}

/**
 滑动主视图
 */
-(void)bk_didScrollSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView
{
    
}

/**
 主视图即将停止拖拽
 */
-(void)bk_willEndDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView withVelocity:(CGPoint)velocity targetContentOffset:(nonnull inout CGPoint *)targetContentOffset
{
    
}

/**
 主视图停止拖拽
 */
-(void)bk_didEndDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView willDecelerate:(BOOL)decelerate
{
    
}

/**
 主视图惯性结束
 */
-(void)bk_didEndDeceleratingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView
{
    
}

@end
