//
//  BKPageControlMenu.h
//  BKPageControlView
//
//  Created by BIKE on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlMenu : UIControl

#pragma mark - 索引

/// 显示在的索引 默认-1
@property (nonatomic,assign) NSInteger displayIndex;

#pragma mark - 属性

/// 内容
@property (nonatomic,copy,readonly) NSString * text;
/// 内容颜色
@property (nonatomic,strong,readonly) UIColor * textColor;
/// 内容字号
@property (nonatomic,strong,readonly) UIFont * font;
/// 行数
@property (nonatomic,assign,readonly) NSUInteger numberOfLines;
/// 行间距
@property (nonatomic,assign,readonly) CGFloat lineSpacing;

/// 标题赋值
/// @param title 内容
/// @param textColor 内容颜色
/// @param font 内容字号
/// @param numberOfLines 行数
/// @param lineSpacing 行间距
-(void)assignTitle:(nullable NSString*)title textColor:(UIColor*)textColor font:(UIFont*)font numberOfLines:(NSUInteger)numberOfLines lineSpacing:(CGFloat)lineSpacing;

/// 内容插入量
@property (nonatomic,assign) UIEdgeInsets contentInset;

/// 标题背景颜色
@property (nonatomic,strong) UIColor * titleBgViewColor;
/// 标题背景插入量
@property (nonatomic,assign) UIEdgeInsets titleBgContentInset;
/// 标题背景角度
@property (nonatomic,assign) CGFloat titleBgAngle;

/// 图标
@property (nonatomic,strong) UIImageView * iconImageView;
/// 选中的图标
@property (nonatomic,strong) UIImageView * sIconImageView;

/// 消息数
@property (nonatomic,strong) UILabel * messageCountLab;

@end

NS_ASSUME_NONNULL_END
