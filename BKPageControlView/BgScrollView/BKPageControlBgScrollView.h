//
//  BKPageControlBgScrollView.h
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/10.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BKPageControlBgScrollViewScrollOrder) {//主视图滑动顺序
    BKPageControlBgScrollViewScrollOrderNormal = 0,                //正常滑动顺序
    BKPageControlBgScrollViewScrollOrderFirstScrollContentView     //先滑动内容视图
};

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlBgScrollView : UIScrollView

/**
 主视图的滑动顺序
 */
@property (nonatomic,assign) BKPageControlBgScrollViewScrollOrder scrollOrder;
/**
 SDK内部添加内容插入量
 使用contentInset时已减去此属性添加的插入量
 */
@property (nonatomic,assign) UIEdgeInsets interiorAddContentInsets;

@end

NS_ASSUME_NONNULL_END
