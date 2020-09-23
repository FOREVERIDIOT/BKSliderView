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
#import "ExampleViewTController.h"

@interface SecondViewController ()<BKPageControlViewDelegate>

@property (nonatomic,strong) BKPageControlView * pageControlView;
@property (nonatomic,strong) NSMutableArray * viewControllers;

@end

@implementation SecondViewController

-(NSMutableArray *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray array];
    }
    return _viewControllers;
}

#pragma mark - viewDidLoad

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
            self.title = @"嵌套pageControlView用手势滑动演示Demo";
        }
            break;
        case 4:
        {
            self.title = @"换子控制器mainScrollview演示Demo";
        }
            break;
        default:
            break;
    }
    
    [self.view addSubview:self.pageControlView];
}

-(void)dealloc
{
    NSLog(@"释放SecondViewController");
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _pageControlView.frame = CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height());
}

#pragma mark - BKPageControlView

-(BKPageControlView*)pageControlView
{
    if (!_pageControlView) {
        NSMutableArray * titles = [NSMutableArray array];
        for (int i = 0 ; i < 10; i++) {
            NSString * title = nil;
            if (i == 0) {
                title = [NSString stringWithFormat:@"换行\n换行\n换行\n第%d个", i];
            }else if (i == 3) {
                title = [NSString stringWithFormat:@"换行\n第%d个", i];
            }else if (i == 5) {
                title = [NSString stringWithFormat:@"比较长的第%d个", i];
            }else {
                title = [NSString stringWithFormat:@"第%d个", i];
            }
            [titles addObject:title];
            [self.viewControllers addObject:@""];
        }

        _pageControlView = [[BKPageControlView alloc] initWithFrame:CGRectZero superVC:self menuTitles:[titles copy] delegate:self];
        _pageControlView.menuView.menuNumberOfLines = 2;
        _pageControlView.menuView.bk_height = 70;
        [self.view addSubview:_pageControlView];
        
        switch (self.selectIndexPath.row) {
            case 1:
            {
                _pageControlView.displayIndex = 5;
            }
                break;
            case 2:
            {
                UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
                yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
                _pageControlView.headerView = yellowColorHeaderView;
            }
                break;
            case 3:
            {
                UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
                yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
                _pageControlView.headerView = yellowColorHeaderView;
                
//                ThirdViewController * vc = [[ThirdViewController alloc] init];
//                vc.title = @"测试pageControlView嵌套pageControlView";
//                NSMutableArray * childControllers = [self.pageControlView.childControllers mutableCopy];
//                [childControllers insertObject:vc atIndex:1];
//                self.pageControlView.childControllers = [childControllers copy];
            }
                break;
            case 4:
            {
                _pageControlView.bgScrollView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
                
                UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
                yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
                _pageControlView.headerView = yellowColorHeaderView;
                
//                ExampleViewTController * vc = [[ExampleViewTController alloc] init];
//                vc.title = @"测试换子控制器mainScrollview";
//                NSMutableArray * childControllers = [self.pageControlView.childControllers mutableCopy];
//                [childControllers insertObject:vc atIndex:1];
//                self.pageControlView.childControllers = [childControllers copy];
            }
                break;
            default:
                break;
        }
    }
    return _pageControlView;
}

#pragma mark - BKPageControlViewDelegate

-(UIViewController*)pageControlView:(BKPageControlView *)pageControlView initializeIndex:(NSUInteger)index
{
    id obj = self.viewControllers[index];
    if ([obj isKindOfClass:[UIViewController class]]) {
        return (UIViewController*)obj;
    }else {
        ExampleViewController * vc = [[ExampleViewController alloc] init];
        [self.viewControllers replaceObjectAtIndex:index withObject:vc];
        return vc;
    }
}

@end
