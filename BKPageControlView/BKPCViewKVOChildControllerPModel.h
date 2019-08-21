//
//  BKPCViewKVOChildControllerPModel.h
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2019/8/20.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BKPageControlViewController.h"
#import "UIViewController+BKPageControlView.h"

//修改主滚动视图 userInfo @{@"bk_index" : @(索引), @"bk_mainScrollView" : 主滚动视图UIScrollView}
UIKIT_EXTERN NSString * _Nonnull const kBKPCViewChangeMainScrollViewNotification;
//修改主滚动视图的contentSize userInfo @{@"bk_index" : @(索引), @"bk_mainScrollView" : 主滚动视图UIScrollView}
UIKIT_EXTERN NSString * _Nonnull const kBKPCViewChangeMainScrollViewContentSizeNotification;

NS_ASSUME_NONNULL_BEGIN

@interface BKPCViewKVOChildControllerPModel : NSObject

/**
 控制器
 */
@property (nonatomic,weak,readonly) UIViewController * childController;

/**
 初始化

 @param childController 子控制器
 @return BKPCViewKVOChildControllerPModel
 */
-(instancetype)initWithChildController:(nonnull UIViewController*)childController;

@end

NS_ASSUME_NONNULL_END
