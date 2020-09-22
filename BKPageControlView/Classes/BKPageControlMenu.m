//
//  BKPageControlMenu.m
//  BKPageControlView
//
//  Created by BIKE on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKPageControlMenu.h"
#import "UIView+BKPageControlView.h"

@interface BKPageControlMenu()

/// 标题背景
@property (nonatomic,strong) UIView * bgView;
/// 标题
@property (nonatomic,strong) UILabel * titleLab;

@end

@implementation BKPageControlMenu

#pragma mark - init

-(instancetype)initWithIdentifer:(NSString*)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        self.displayIndex = -1;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        [self initUI];
        
        UITapGestureRecognizer * selfTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
        [self addGestureRecognizer:selfTap];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.bgView.frame = CGRectMake(self.titleBgContentInset.left, self.titleBgContentInset.top, self.width - self.titleBgContentInset.left - self.titleBgContentInset.right, self.height - self.titleBgContentInset.top - self.titleBgContentInset.bottom);
    UIBezierPath * bgViewPath = [UIBezierPath bezierPathWithRoundedRect:self.bgView.bounds cornerRadius:self.titleBgAngle];
    CAShapeLayer * bgViewMaskLayer = [CAShapeLayer layer];
    bgViewMaskLayer.path = bgViewPath.CGPath;
    bgViewMaskLayer.frame = self.bgView.bounds;
    self.bgView.layer.mask = bgViewMaskLayer;
    
    self.titleLab.frame = CGRectMake(self.contentInset.left, self.contentInset.top, self.width - self.contentInset.left - self.contentInset.right, self.height - self.contentInset.top - self.contentInset.bottom);
}

#pragma mark - initUI

-(void)initUI
{
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgView];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLab];
    
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.iconImageView];
    
    self.sIconImageView = [[UIImageView alloc] init];
    self.sIconImageView.clipsToBounds = YES;
    self.sIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.sIconImageView];
    
    self.messageCountLab = [[UILabel alloc] init];
    [self addSubview:self.messageCountLab];
}

#pragma mark - 触发事件

-(void)selfTap
{
    if (self.clickSelfCallBack) {
        self.clickSelfCallBack(self);
    }
}

#pragma mark - 标题属性

-(void)assignTitle:(NSString*)title textColor:(UIColor*)textColor font:(UIFont*)font numberOfLines:(NSUInteger)numberOfLines lineSpacing:(CGFloat)lineSpacing
{
    _text = title;
    _textColor = textColor;
    _font = font;
    _numberOfLines = numberOfLines;
    _lineSpacing = lineSpacing;
    
    if ([_text length] > 0) {
        NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = NSTextAlignmentCenter;
        para.lineBreakMode = NSLineBreakByTruncatingTail;
        para.lineSpacing = _lineSpacing;
        
        NSDictionary * attributes = @{NSFontAttributeName:_font,
                                      NSForegroundColorAttributeName:_textColor,
                                      NSParagraphStyleAttributeName:para
                                      };
        
        NSAttributedString * string = [[NSAttributedString alloc] initWithString:_text attributes:attributes];
        self.titleLab.attributedText = string;
        self.titleLab.numberOfLines = _numberOfLines;
    }else {
        self.titleLab.attributedText = nil;
    }
}

-(void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    [self layoutSubviews];
}

#pragma mark - 标题背景属性

-(void)setTitleBgViewColor:(UIColor *)titleBgViewColor
{
    _titleBgViewColor = titleBgViewColor;
    self.bgView.backgroundColor = _titleBgViewColor;
}

-(void)setTitleBgContentInset:(UIEdgeInsets)titleBgContentInset
{
    _titleBgContentInset = titleBgContentInset;
    [self layoutSubviews];
}

-(void)setTitleBgAngle:(CGFloat)titleBgAngle
{
    _titleBgAngle = titleBgAngle;
    [self layoutSubviews];
}

@end
