//
//  BKSlideMenu.m
//  BKSliderView
//
//  Created by zhaolin on 2018/11/14.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKSlideMenu.h"

@implementation BKSlideMenu

-(instancetype)initWithIdentifer:(NSString*)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.displayIndex = -1;
    }
    return self;
}

@end
