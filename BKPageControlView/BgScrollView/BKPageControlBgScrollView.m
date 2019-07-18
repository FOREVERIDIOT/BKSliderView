//
//  BKPageControlBgScrollView.m
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/10.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPageControlBgScrollView.h"

@interface BKPageControlBgScrollView()

@end

@implementation BKPageControlBgScrollView

#pragma mark - SDK内部使用的内容添加插入量

-(UIEdgeInsets)interiorContentInsets
{
    return UIEdgeInsetsMake(self.contentInset.top - _interiorAddContentInsets.top,
                            self.contentInset.left - _interiorAddContentInsets.left,
                            self.contentInset.bottom - _interiorAddContentInsets.bottom,
                            self.contentInset.right - _interiorAddContentInsets.right);
}

#pragma mark - SDK内部添加内容插入量

-(void)setInteriorAddContentInsets:(UIEdgeInsets)interiorAddContentInsets
{
    UIEdgeInsets interiorContentInsets = self.interiorContentInsets;
    _interiorAddContentInsets = interiorAddContentInsets;
    self.contentInset = UIEdgeInsetsMake(interiorContentInsets.top + _interiorAddContentInsets.top,
                                         interiorContentInsets.left + _interiorAddContentInsets.left,
                                         interiorContentInsets.bottom + _interiorAddContentInsets.bottom,
                                         interiorContentInsets.right + _interiorAddContentInsets.right);
}

@end
