//
//  BKPCVBgScrollView.h
//  Pods
//
//  Created by 毕珂 on 2020/9/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class BKPageControlBgScrollView;

#ifndef BKPCVBgScrollView_h
#define BKPCVBgScrollView_h

@protocol BKPCVBgScrollView <NSObject>

@optional

#pragma mark - 滑动主视图

/**
 开始滑动主视图
 
 @param bgScrollView 主滚动视图
 */
-(void)bk_willBeginDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

/**
 滑动主视图
 
 @param bgScrollView 主滚动视图
 */
-(void)bk_didScrollSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

/**
 主视图即将停止拖拽
 
 @param bgScrollView 主滚动视图
 @param velocity 速度
 @param targetContentOffset 目标偏移量
 */
-(void)bk_willEndDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView withVelocity:(CGPoint)velocity targetContentOffset:(nonnull inout CGPoint *)targetContentOffset;

/**
 主视图停止拖拽
 
 @param bgScrollView 主滚动视图
 @param decelerate 是否有惯性
 */
-(void)bk_didEndDraggingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

/**
 主视图惯性结束
 
 @param bgScrollView 主滚动视图
 */
-(void)bk_didEndDeceleratingSuperBgScrollView:(nonnull BKPageControlBgScrollView*)bgScrollView;

@end

#endif /* BKPCVBgScrollView_h */
