//
//  BKPageControlViewController.h
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/5.
//  Copyright © 2019 BIKE. All rights reserved.
//

#ifndef BKPageControlViewController_h
#define BKPageControlViewController_h

@protocol BKPageControlViewController <NSObject>

@required

/**
 所在索引
 */
@property (nonatomic,assign) NSUInteger bk_index;
/**
 分页控制视图所在的父控制器
 */
@property (nonatomic,weak) UIViewController * bk_superVC;
/**
 子控制器的主滚动视图(用于计算出BKPageControlView主视图的contentSize)
 此属性会自动获取，也可以自己赋值更改。
 */
@property (nonatomic,weak) UIScrollView * bk_mainScrollView;

@end

#endif /* BKPageControlViewController_h */
