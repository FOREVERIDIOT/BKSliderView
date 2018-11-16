//
//  BKSlideMenuModel.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/15.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BKSlideMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKSlideTotalMenuPropertyModel : NSObject

/**
 字号
 */
@property (nonatomic,strong) UIFont * font;
/**
 颜色
 */
@property (nonatomic,strong) UIColor * color;
/**
 坐标
 */
@property (nonatomic,assign) CGRect rect;
/**
 menu的title宽
 */
@property (nonatomic,assign) CGFloat titleWidth;

@end

@interface BKSlideMenuModel : NSObject

/**
 所有的menu附加属性
 */
@property (nonatomic,strong) NSMutableArray<BKSlideTotalMenuPropertyModel*> * total;
/**
 可见的索引
 */
@property (nonatomic,strong) NSMutableArray<NSNumber*> * visibleIndexs;
/**
 可见的menu
 */
@property (nonatomic,strong) NSMutableArray<BKSlideMenu*> * visible;
/**
 缓存的menu
 */
@property (nonatomic,strong) NSMutableArray<BKSlideMenu*> * cache;

@end

NS_ASSUME_NONNULL_END
