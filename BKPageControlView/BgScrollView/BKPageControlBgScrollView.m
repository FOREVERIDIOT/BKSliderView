//
//  BKPageControlBgScrollView.m
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/10.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPageControlBgScrollView.h"

@interface BKPageControlBgScrollView()

/**
 记录系统内容插入量
 */
@property (nonatomic,assign) UIEdgeInsets recordSysContentInset;

@end

@implementation BKPageControlBgScrollView

#pragma mark - 内容插入量(系统)

-(UIEdgeInsets)contentInset
{
    return UIEdgeInsetsMake(self.recordSysContentInset.top - self.interiorAddContentInsets.top,
                            self.recordSysContentInset.left - self.interiorAddContentInsets.left,
                            self.recordSysContentInset.bottom - self.interiorAddContentInsets.bottom,
                            self.recordSysContentInset.right - self.interiorAddContentInsets.right);
}

-(void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    self.recordSysContentInset = contentInset;
}

#pragma mark - SDK内部添加内容插入量

-(void)setInteriorAddContentInsets:(UIEdgeInsets)interiorAddContentInsets
{
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top + interiorAddContentInsets.top,
                                         self.contentInset.left + interiorAddContentInsets.left,
                                         self.contentInset.bottom + interiorAddContentInsets.bottom,
                                         self.contentInset.right + interiorAddContentInsets.right);
    _interiorAddContentInsets = interiorAddContentInsets;
}

@end
