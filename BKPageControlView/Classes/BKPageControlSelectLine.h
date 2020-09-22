//
//  BKPageControlSelectLine.h
//  TestHomePage
//
//  Created by BIKE on 2020/8/25.
//  Copyright © 2020 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlSelectLine : UIView


/// 背景颜色
/// 不能使用backgroundColor方法 在xcode看图层时会走此方法导致渐变色删除
@property (nonatomic,strong,nullable) UIColor * bgColor;
/**
 颜色数组
 */
@property (nonatomic,copy,nullable) NSArray<UIColor*> * colors;

@end

NS_ASSUME_NONNULL_END
