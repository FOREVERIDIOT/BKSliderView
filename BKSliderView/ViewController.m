//
//  ViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "ViewController.h"
#import "BKSlideView.h"
#import "ExampleViewController.h"
#import "UIView+BKSlideView.h"

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

@interface ViewController ()<BKSlideViewDelegate>

@property (nonatomic,strong) BKSlideView * slideView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"基本展示界面";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray * viewControllers = [NSMutableArray array];
    for (int i = 0 ; i<10; i++) {
        ExampleViewController * vc = [[ExampleViewController alloc]init];
        if (i == 3) {
            vc.title = [NSString stringWithFormat:@"换行\n第%d个",i];
        }else if (i == 5) {
            vc.title = [NSString stringWithFormat:@"比较长的第%d个",i];
        }else {
            vc.title = [NSString stringWithFormat:@"第%d个",i];
        }
        [viewControllers addObject:vc];
    }
    
    self.slideView = [[BKSlideView alloc] initWithFrame:CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height()) delegate:self viewControllers:viewControllers];
    self.slideView.menuView.menuNumberOfLines = 2;
    self.slideView.menuView.bk_height = 70;
    self.slideView.selectIndex = 5;
//    self.slideView.menuView.menuTypesetting = BKSlideMenuTypesettingEqualWidth;
    [self.view addSubview:self.slideView];
    
    UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
    self.slideView.headerView = yellowColorHeaderView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ExampleViewController * vc = [[ExampleViewController alloc]init];
        vc.title = @"我是新添加的vc";
        NSMutableArray * viewControllers = [self.slideView.viewControllers mutableCopy];
        [viewControllers addObject:vc];
        self.slideView.viewControllers = viewControllers;
    });
}

-(void)slideView:(BKSlideView*)slideView createViewControllerWithIndex:(NSUInteger)index
{
    ExampleViewController * vc = (ExampleViewController*)self.slideView.viewControllers[index];
    [vc createUIWithIndex:index];
}

-(void)slideViewDidChangeFrame:(BKSlideView *)slideView
{
    NSLog(@"修改详情内容视图的frame");
    [self.slideView.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ExampleViewController * vc = (ExampleViewController*)obj;
        [vc changeContentFrame];
    }];
}

-(void)slideView:(BKSlideView *)slideView leaveIndex:(NSUInteger)leaveIndex
{
    NSLog(@"离开了%ld",leaveIndex);
}

-(void)slideView:(BKSlideView *)slideView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex
{
    NSLog(@"离开了%ld 来到了%ld",leaveIndex,switchIndex);
}

-(void)slideView:(BKSlideView *)slideView didScrollBgScrollView:(UIScrollView*)bgScrollView
{
    NSLog(@"滑动主视图");
}

-(void)slideView:(BKSlideView *)slideView willBeginDraggingBgScrollView:(UIScrollView*)bgScrollView
{
    NSLog(@"开始滑动主视图");
}

-(void)slideView:(BKSlideView *)slideView didEndDeceleratingBgScrollView:(UIScrollView*)bgScrollView
{
    NSLog(@"主视图惯性结束");
}

-(void)slideView:(BKSlideView *)slideView didEndDraggingBgScrollView:(UIScrollView*)bgScrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"主视图停止拖拽");
}

@end
