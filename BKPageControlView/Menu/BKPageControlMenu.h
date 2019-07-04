//
//  BKPageControlMenu.h
//  BKPageControlView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlMenu : UIView

#pragma mark - 创建

/**
 标识符
 */
@property (nonatomic,copy) NSString * identifier;
/**
 创建menu
 
 @param identifier 标识符
 @return menu
 */
-(instancetype)initWithIdentifer:(NSString*)identifier;

#pragma mark - 索引

/**
 显示在的索引 默认-1
 */
@property (nonatomic,assign) NSInteger displayIndex;

#pragma mark - 属性

/**
 内容
 */
@property (nonatomic,copy) NSString * text;
/**
 内容颜色
 */
@property (nonatomic,strong) UIColor * textColor;
/**
 内容字号
 */
@property (nonatomic,strong) UIFont * font;
/**
 行数
 */
@property (nonatomic,assign) NSUInteger numberOfLines;
/**
 行间距
 */
@property (nonatomic,assign) CGFloat lineSpacing;
/**
 内容插入量
 */
@property (nonatomic,assign) UIEdgeInsets contentInset;
/**
 内容对齐方式
 */
@property (nonatomic,assign) NSTextAlignment textAlignment;
/**
 icon
 */
@property (nonatomic,strong) UIImageView * iconImageView;
/**
 选中的icon
 */
@property (nonatomic,strong) UIImageView * sIconImageView;

#pragma mark - 触发事件

@property (nonatomic,copy) void (^clickSelfCallBack)(BKPageControlMenu * menu);

@end

NS_ASSUME_NONNULL_END
