//
//  BKSlideView.h
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSlideMenuView.h"

@protocol BKSlideViewDelegate <NSObject>

@optional
/**
 *     创建Cell 相当于 UITableViewCell里的 if{} 括号内
 **/
-(void)initCell:(UITableViewCell*)cell withIndex:(NSIndexPath*)indexPath;

/**
 *     复用Cell 相当于 UITableViewCell里的 if{} 括号外
 **/
-(void)reuseCell:(UITableViewCell*)cell withIndex:(NSIndexPath*)indexPath;

@required
/**
 *     滑动 slideView
 **/
-(void)scrollSlideView:(BKSlideView*)theSlideView;

/**
 *     结束滑动 slideView
 **/
-(void)endScrollSlideView:(BKSlideView*)theSlideView;

@end

@interface BKSlideView : UITableView

@property (nonatomic,assign,readonly) NSInteger pageNum;

@property (nonatomic,assign) id <BKSlideViewDelegate>customDelegate;

/**
  *     创建方法 pageNum 是页数
 **/
-(instancetype)initWithFrame:(CGRect)frame allPageNum:(NSInteger)pageNum delegate:(id<BKSlideViewDelegate>)customDelegate;

/**
 *     移动 SlideView 至第 index 页
 **/
-(void)rollSlideViewToIndexView:(NSInteger)index;

@end
