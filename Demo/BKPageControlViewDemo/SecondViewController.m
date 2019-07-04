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

@interface SecondViewController ()<BKPageControlViewDelegate>

@property (nonatomic,strong) BKPageControlView * sliderView;

@end

@implementation SecondViewController

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _sliderView.frame = CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height());
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"基本展示界面";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    self.sliderView = [[BKPageControlView alloc] initWithFrame:CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height()) delegate:self childControllers:viewControllers superVC:self];
    self.sliderView.menuView.menuNumberOfLines = 2;
    self.sliderView.menuView.bk_height = 70;
    self.sliderView.selectIndex = 5;
//    self.slideView.menuView.menuTypesetting = BKSlideMenuTypesettingEqualWidth;
    [self.view addSubview:self.sliderView];
    
    UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
    self.sliderView.headerView = yellowColorHeaderView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ExampleViewController * vc = [[ExampleViewController alloc]init];
        vc.title = @"我是新添加的vc";
        NSMutableArray * viewControllers = [self.sliderView.childControllers mutableCopy];
        [viewControllers addObject:vc];
        self.sliderView.childControllers = viewControllers;
    });
}

-(void)sliderView:(BKPageControlView *)sliderView willLeaveIndex:(NSUInteger)leaveIndex
{
    NSLog(@"离开了%ld",leaveIndex);
}

-(void)sliderView:(BKPageControlView *)sliderView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex
{
    NSLog(@"离开了%ld 来到了%ld",leaveIndex,switchIndex);
}

-(void)sliderView:(BKPageControlView *)sliderView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
{
    NSLog(@"离开中%ld 来到中%ld 百分比%f",leavingIndex,switchingIndex,percentage);
}

-(void)sliderView:(BKPageControlView *)sliderView didScrollBgScrollView:(UIScrollView *)bgScrollView
{
    NSLog(@"滑动主视图");
}

-(void)sliderView:(BKPageControlView *)sliderView willBeginDraggingBgScrollView:(UIScrollView *)bgScrollView
{
    NSLog(@"开始滑动主视图");
}

-(void)sliderView:(BKPageControlView *)sliderView didEndDeceleratingBgScrollView:(UIScrollView *)bgScrollView
{
    NSLog(@"主视图惯性结束");
}

-(void)sliderView:(BKPageControlView *)sliderView didEndDraggingBgScrollView:(UIScrollView *)bgScrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"主视图停止拖拽");
}

@end
