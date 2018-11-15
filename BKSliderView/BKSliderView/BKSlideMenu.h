//
//  BKSlideMenu.h
//  BKSliderView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKSlideMenu : UILabel

/**
 标识符
 */
@property (nonatomic,copy) NSString * identifier;

/**
 显示在的索引 默认-1
 */
@property (nonatomic,assign) NSInteger displayIndex;

/**
 创建menu
 
 @param identifier 标识符
 @return menu
 */
-(instancetype)initWithIdentifer:(NSString*)identifier;

@end

NS_ASSUME_NONNULL_END
