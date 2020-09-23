//
//  Inline.h
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/3.
//  Copyright © 2019 BIKE. All rights reserved.
//

#ifndef Inline_h
#define Inline_h

/**
 判断是否是iPhone X系列
 */
NS_INLINE BOOL is_iPhoneX_series() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        if (window.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

/**
 获取系统导航高度
 */
NS_INLINE CGFloat get_system_nav_height() {
    return is_iPhoneX_series() ? (44.f+44.f) : 64.f;
}

#endif /* Inline_h */
