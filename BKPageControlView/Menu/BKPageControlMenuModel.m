//
//  BKPageControlMenuModel.m
//  BKPageControlView
//
//  Created by zhaolin on 2018/11/15.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKPageControlMenuModel.h"

@implementation BKPageControlMenuModel

-(NSMutableArray<BKPageControlMenuPropertyModel *> *)total
{
    if (!_total) {
        _total = [NSMutableArray array];
    }
    return _total;
}

-(NSMutableArray<NSNumber *> *)visibleIndexs
{
    if (!_visibleIndexs) {
        _visibleIndexs = [NSMutableArray array];
    }
    return _visibleIndexs;
}

-(NSMutableArray<BKPageControlMenu *> *)visible
{
    if (!_visible) {
        _visible = [NSMutableArray array];
    }
    return _visible;
}

-(NSMutableArray<BKPageControlMenu *> *)cache
{
    if (!_cache) {
        _cache = [NSMutableArray array];
    }
    return _cache;
}

@end
