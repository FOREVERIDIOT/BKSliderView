//
//  BKPageControlViewController.h
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/3.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlViewController : UIViewController

/**
 所在索引
 */
@property (nonatomic,assign) NSUInteger index;
/**
 主滚动视图(用于计算出BKPageControlView主视图的contentSize)
 此属性会自动获取，也可以自己赋值更改。
 */
@property (nonatomic,weak) UIScrollView * mainScrollView;

@end

NS_ASSUME_NONNULL_END
