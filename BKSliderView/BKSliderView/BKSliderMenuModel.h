//
//  BKSliderMenuModel.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/15.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BKSliderMenuPropertyModel.h"
#import "BKSliderMenu.h"

NS_ASSUME_NONNULL_BEGIN


@interface BKSliderMenuModel : NSObject

/**
 所有的menu附加属性
 */
@property (nonatomic,strong) NSMutableArray<BKSliderMenuPropertyModel*> * total;
/**
 可见的索引
 */
@property (nonatomic,strong) NSMutableArray<NSNumber*> * visibleIndexs;
/**
 可见的menu
 */
@property (nonatomic,strong) NSMutableArray<BKSliderMenu*> * visible;
/**
 缓存的menu
 */
@property (nonatomic,strong) NSMutableArray<BKSliderMenu*> * cache;

@end

NS_ASSUME_NONNULL_END
