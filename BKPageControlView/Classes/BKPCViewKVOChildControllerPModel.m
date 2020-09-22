//
//  BKPCViewKVOChildControllerPModel.m
//  DSCnliveShopSDK
//
//  Created by BIKE on 2019/8/20.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPCViewKVOChildControllerPModel.h"

NSString * const kBKPCViewChangeMainScrollViewNotification = @"kBKPCViewChangeMainScrollViewNotification";
NSString * const kBKPCViewChangeMainScrollViewContentSizeNotification = @"kBKPCViewChangeMainScrollViewContentSizeNotification";

@implementation BKPCViewKVOChildControllerPModel
@synthesize childController = _childController;

-(void)setChildController:(UIViewController * _Nullable)childController
{
    _childController = childController;
}

#pragma mark - init

-(instancetype)initWithChildController:(UIViewController *)childController
{
    self = [super init];
    if (self) {
        self.childController = childController;
        
        [self addObserver:self forKeyPath:@"childController.bk_mainScrollView" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"childController.bk_mainScrollView.contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"childController.bk_mainScrollView"];
    [self removeObserver:self forKeyPath:@"childController.bk_mainScrollView.contentSize"];
}

#pragma mark - kvo

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"childController.bk_mainScrollView"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kBKPCViewChangeMainScrollViewNotification object:nil userInfo:@{@"bk_index" : @(self.childController.bk_index), @"bk_mainScrollView" : self.childController.bk_mainScrollView ? self.childController.bk_mainScrollView : [NSNull null]}];
        
    }else if ([keyPath isEqualToString:@"childController.bk_mainScrollView.contentSize"]) {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kBKPCViewChangeMainScrollViewContentSizeNotification object:nil userInfo:@{@"bk_index" : @(self.childController.bk_index), @"bk_mainScrollView" : self.childController.bk_mainScrollView ? self.childController.bk_mainScrollView : [NSNull null]}];
        }
    }
}

@end
