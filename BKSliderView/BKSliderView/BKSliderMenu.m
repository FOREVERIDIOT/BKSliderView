//
//  BKSliderMenu.m
//  BKSliderView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKSliderMenu.h"
#import "NSAttributedString+BKSliderView.h"
#import "UIView+BKSliderView.h"

@implementation BKSliderMenu
@synthesize text = _text;
@synthesize textColor = _textColor;
@synthesize font = _font;

#pragma mark - init

-(instancetype)initWithIdentifer:(NSString*)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.displayIndex = -1;
        self.numberOfLines = 1;
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * selfTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
        [self addGestureRecognizer:selfTap];
    }
    return self;
}

#pragma mark - 属性

-(NSString*)text
{
    if (!_text) {
        _text = @"";
    }
    return _text;
}

-(void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay];
}

-(UIColor*)textColor
{
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay];
}

-(UIFont*)font
{
    if (!_font) {
        _font = [UIFont systemFontOfSize:17];
    }
    return _font;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    [self setNeedsDisplay];
}

-(void)setNumberOfLines:(NSUInteger)numberOfLines
{
    _numberOfLines = numberOfLines;
    [self setNeedsDisplay];
}

-(void)setLineSpacing:(CGFloat)lineSpacing
{
    _lineSpacing = lineSpacing;
    [self setNeedsDisplay];
}

-(void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    [self setNeedsDisplay];
}

-(void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self setNeedsDisplay];
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
    para.alignment = self.textAlignment;
    para.lineBreakMode = NSLineBreakByTruncatingTail;
    para.lineSpacing = self.lineSpacing;
    
    NSDictionary * attributes = @{NSFontAttributeName:self.font,
                     NSForegroundColorAttributeName:self.textColor,
                     NSParagraphStyleAttributeName:para
                     };
    
    NSAttributedString * string = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    
    CGFloat height = 0;
    if (self.numberOfLines == 0) {
        height = [string calculateHeightWithUIWidth:MAXFLOAT];
    }else {
        NSInteger lineCount = [[self.text componentsSeparatedByString:@"\n"] count];
        if (self.numberOfLines < lineCount) {
            lineCount = self.numberOfLines;
        }
        NSMutableString * tempString = [NSMutableString string];
        [tempString appendString:@" "];
        for (int i = 1; i < lineCount; i++) {
            [tempString appendString:@"\n "];
        }
        NSAttributedString * tempAttrString = [[NSAttributedString alloc] initWithString:tempString attributes:attributes];
        height = [tempAttrString calculateHeightWithUIWidth:MAXFLOAT];
    }
    
    [string drawInRect:CGRectMake(self.contentInset.left,
                                  (self.bk_height - height)/2 + self.contentInset.top - self.contentInset.bottom,
                                  self.bk_width - self.contentInset.left - self.contentInset.right,
                                  height)];
}

#pragma mark - 触发事件

-(void)selfTap
{
    if (self.clickSelfCallBack) {
        self.clickSelfCallBack(self);
    }
}

@end
