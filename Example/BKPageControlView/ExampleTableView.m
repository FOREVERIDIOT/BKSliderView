//
//  ExampleTableView.m
//  BKPageControlViewDemo
//
//  Created by zhaolin on 2019/7/8.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "ExampleTableView.h"

@implementation ExampleTableView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hitTestCallBack) {
        self.hitTestCallBack(point);
    }
    return [super hitTest:point withEvent:event];
}

@end
