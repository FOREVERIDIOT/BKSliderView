//
//  ViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "ViewController.h"
#import "BKSliderView.h"
#import "ExampleViewController.h"
#import "UIView+BKSliderView.h"

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

@interface ViewController ()<BKSliderViewDelegate>

@property (nonatomic,strong) BKSliderView * sliderView;

@end

@implementation ViewController

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
        vc.index = i;
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
    
    self.sliderView = [[BKSliderView alloc] initWithFrame:CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height()) delegate:self viewControllers:viewControllers];
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
        NSMutableArray * viewControllers = [self.sliderView.viewControllers mutableCopy];
        [viewControllers addObject:vc];
        self.sliderView.viewControllers = viewControllers;
    });
}

-(void)sliderView:(BKSliderView *)sliderView firstDisplayViewController:(UIViewController *)viewController index:(NSUInteger)index
{
    ExampleViewController * vc = (ExampleViewController*)viewController;
    [vc firstDisplay];
}

-(void)sliderView:(BKSliderView *)sliderView willLeaveIndex:(NSUInteger)leaveIndex
{
    NSLog(@"离开了%ld",leaveIndex);
}

-(void)sliderView:(BKSliderView *)sliderView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex
{
    NSLog(@"离开了%ld 来到了%ld",leaveIndex,switchIndex);
}

-(void)sliderView:(BKSliderView *)sliderView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage
{
    NSLog(@"离开中%ld 来到中%ld 百分比%f",leavingIndex,switchingIndex,percentage);
}

-(void)sliderView:(BKSliderView *)sliderView didScrollBgScrollView:(UIScrollView *)bgScrollView
{
    NSLog(@"滑动主视图");
}

-(void)sliderView:(BKSliderView *)sliderView willBeginDraggingBgScrollView:(UIScrollView *)bgScrollView
{
    NSLog(@"开始滑动主视图");
}

-(void)sliderView:(BKSliderView *)sliderView didEndDeceleratingBgScrollView:(UIScrollView *)bgScrollView
{
    NSLog(@"主视图惯性结束");
}

-(void)sliderView:(BKSliderView *)sliderView didEndDraggingBgScrollView:(UIScrollView *)bgScrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"主视图停止拖拽");
}

@end
