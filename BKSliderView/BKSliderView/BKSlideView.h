//
//  BKSlideView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSlideMenuView.h"

@protocol BKSlideViewDelegate <NSObject>

@required
/**
 *     滑动 slideView
 */
-(void)scrollSlideView:(UICollectionView*)slideView;

/**
 *     结束滑动 slideView
 */
-(void)endScrollSlideView:(UICollectionView*)slideView;

/**
 *  创建UI
 *
 *  @param view  第几页上的view （创建UI在这里创建）
 *  @param index 第几页
 */
-(void)initInView:(UIView*)view atIndex:(NSInteger)index;

@end

@interface BKSlideView : UIView

/**
 *  基础view
 */
@property (nonatomic,strong,readonly) UICollectionView * slideView;

/**
 *  一共几页 从1开始
 */
@property (nonatomic,assign,readonly) NSInteger pageNum;

/**
 *  自定义delegate
 */
@property (nonatomic,assign) id <BKSlideViewDelegate>customDelegate;

/**
 *     创建方法 pageNum 是页数
 */
-(instancetype)initWithFrame:(CGRect)frame allPageNum:(NSInteger)pageNum delegate:(id<BKSlideViewDelegate>)customDelegate;

/**
 *     移动 SlideView 至第 index 页
 */
-(void)rollSlideViewToIndexView:(NSInteger)index;

/**
 *  获取当前显示View
 */
-(UIView*)getDisplayView;

@end
