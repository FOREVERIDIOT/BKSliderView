//
//  BKPageControlKVOModel.h
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/8.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKPageControlKVOModel : NSObject

/**
 子控制器
 */
@property (nonatomic,weak,nullable) UIViewController * childController;
/**
 监听的paths数组
 */
@property (nonatomic,copy,nullable) NSArray<NSString*> * kvoKeyPaths;

@end

NS_ASSUME_NONNULL_END
