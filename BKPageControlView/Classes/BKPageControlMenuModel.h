//
//  BKPageControlMenuModel.h
//  BKPageControlView
//
//  Created by BIKE on 2018/11/15.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BKPageControlMenuPropertyModel.h"
#import "BKPageControlMenu.h"

NS_ASSUME_NONNULL_BEGIN


@interface BKPageControlMenuModel : NSObject

/**
 所有的menu附加属性
 */
@property (nonatomic,strong) NSMutableArray<BKPageControlMenuPropertyModel*> * total;
/**
 可见的索引
 */
@property (nonatomic,strong) NSMutableArray<NSNumber*> * visibleIndexs;
/**
 可见的menu
 */
@property (nonatomic,strong) NSMutableArray<BKPageControlMenu*> * visible;
/**
 缓存的menu
 */
@property (nonatomic,strong) NSMutableArray<BKPageControlMenu*> * cache;

@end

NS_ASSUME_NONNULL_END
