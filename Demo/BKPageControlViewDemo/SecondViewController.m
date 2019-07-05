//
//  SecondViewController.m
//  BKPageControlExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "SecondViewController.h"
#import "Inline.h"
#import <BKPageControlView/BKPageControlView.h>
#import "ExampleViewController.h"
#import "UIView+Extension.h"
#import "ThirdViewController.h"

@interface SecondViewController ()<BKPageControlViewDelegate>

@property (nonatomic,strong) BKPageControlView * pageControlView;

@end

@implementation SecondViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    switch (self.selectIndexPath.row) {
        case 0:
        {
            self.title = @"基本演示Demo";
        }
            break;
        case 1:
        {
            self.title = @"开始选中第5个演示Demo";
        }
            break;
        case 2:
        {
            self.title = @"带headerView演示Demo";
        }
            break;
        case 3:
        {
            self.title = @"用手势滑动演示Demo";
        }
            break;
        default:
            break;
    }
    
    NSMutableArray * viewControllers = [NSMutableArray array];
    for (int i = 0 ; i < 10; i++) {
        ExampleViewController * vc = [[ExampleViewController alloc] init];
        if (i == 0) {
            vc.title = [NSString stringWithFormat:@"换行\n换行\n换行\n第%d个",i];
        }else if (i == 3) {
            vc.title = [NSString stringWithFormat:@"换行\n第%d个",i];
        }else if (i == 5) {
            vc.title = [NSString stringWithFormat:@"比较长的第%d个",i];
        }else {
            vc.title = [NSString stringWithFormat:@"第%d个",i];
        }
        [viewControllers addObject:vc];
    }
    
    self.pageControlView = [[BKPageControlView alloc] initWithFrame:CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height()) delegate:self childControllers:viewControllers superVC:self];
    self.pageControlView.menuView.menuNumberOfLines = 2;
    self.pageControlView.menuView.bk_height = 70;
    [self.view addSubview:self.pageControlView];
    
    switch (self.selectIndexPath.row) {
        case 1:
        {
            self.pageControlView.selectIndex = 5;
        }
            break;
        case 2:
        {
            UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
            yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
            self.pageControlView.headerView = yellowColorHeaderView;
        }
            break;
        case 3:
        {
            UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
            yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
            self.pageControlView.headerView = yellowColorHeaderView;
            
            ThirdViewController * vc = [[ThirdViewController alloc] init];
            vc.title = @"测试pageControlView嵌套pageControlView";
            NSMutableArray * childControllers = [self.pageControlView.childControllers mutableCopy];
            [childControllers insertObject:vc atIndex:1];
            self.pageControlView.childControllers = [childControllers copy];
        }
            break;
        default:
            break;
    }
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _pageControlView.frame = CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height());
}

#pragma mark - BKPageControlViewDelegate

/**
 准备离开index
 
 @param leaveIndex 离开的index
 */
-(void)sliderView:(BKPageControlView *)sliderView willLeaveIndex:(NSUInteger)leaveIndex
{
    
}

/**
 切换index中
 
 @param sliderView BKPageControlView
 @param switchingIndex 切换中的index
 @param leavingIndex 离开中的index
 @param percentage 百分比
 */
-(void)sliderView:(BKPageControlView *)sliderView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
{
    
}

/**
 切换index
 
 @param sliderView BKPageControlView
 @param switchIndex 切换的index
 @param leaveIndex 离开的index
 */
-(void)sliderView:(BKPageControlView *)sliderView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex
{
    
}

#pragma mark - 主视图滑动代理

/**
 滑动主视图
 
 @param sliderView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKPageControlView *)sliderView didScrollBgScrollView:(UIScrollView *)bgScrollView
{
    
}

/**
 开始滑动主视图
 
 @param sliderView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKPageControlView *)sliderView willBeginDraggingBgScrollView:(UIScrollView *)bgScrollView
{
    
}

/**
 主视图惯性结束
 
 @param sliderView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKPageControlView *)sliderView didEndDeceleratingBgScrollView:(UIScrollView *)bgScrollView
{
    
}

/**
 主视图停止拖拽
 
 @param sliderView BKPageControlView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKPageControlView *)sliderView didEndDraggingBgScrollView:(UIScrollView *)bgScrollView willDecelerate:(BOOL)decelerate
{
    
}

/**
 设置导航视图中menu上的icon和选中的icon
 
 @param menu menu
 @param iconImageView icon
 @param selectIconImageView 选中的icon
 @param index 索引
 */
-(void)sliderView:(BKPageControlView *)sliderView menu:(BKPageControlMenu *)menu settingIconImageView:(UIImageView *)iconImageView selectIconImageView:(UIImageView *)selectIconImageView atIndex:(NSUInteger)index
{
    
}

@end
