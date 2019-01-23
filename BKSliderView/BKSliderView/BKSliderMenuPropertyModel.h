//
//  BKSliderMenuPropertyModel.h
//  CNLiveDemo
//
//  Created by zhaolin on 2018/11/21.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKSliderMenuPropertyModel : NSObject

/**
 坐标
 */
@property (nonatomic,assign) CGRect rect;
/**
 menu的title宽
 */
@property (nonatomic,assign) CGFloat titleWidth;
/**
 字号
 */
@property (nonatomic,strong) UIFont * font;
/**
 颜色
 */
@property (nonatomic,strong) UIColor * color;

@end

NS_ASSUME_NONNULL_END
