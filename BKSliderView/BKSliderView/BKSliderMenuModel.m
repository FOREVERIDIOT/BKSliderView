//
//  BKSliderMenuModel.m
//  BKSliderView
//
//  Created by zhaolin on 2018/11/15.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKSliderMenuModel.h"

@implementation BKSliderMenuModel

-(NSMutableArray<BKSliderMenuPropertyModel *> *)total
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

-(NSMutableArray<BKSliderMenu *> *)visible
{
    if (!_visible) {
        _visible = [NSMutableArray array];
    }
    return _visible;
}

-(NSMutableArray<BKSliderMenu *> *)cache
{
    if (!_cache) {
        _cache = [NSMutableArray array];
    }
    return _cache;
}

@end
