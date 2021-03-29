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
            self.title = @"嵌套pageControlView演示Demo";
        }
            break;
        case 4:
        {
            self.title = @"2s后插入新controller演示Demo";
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
        NSMutableArray * childControlles = [NSMutableArray array];
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
            ExampleViewController * vc = [[ExampleViewController alloc] init];
            vc.title = title;
            [childControlles addObject:vc];
        }

        _pageControlView = [[BKPageControlView alloc] initWithFrame:CGRectZero superVC:self childControllers:[childControlles copy] delegate:self];
        _pageControlView.menuView.menuNumberOfLines = 2;
        _pageControlView.menuView.bk_height = 70;
        [self.view addSubview:_pageControlView];
        
        switch (self.selectIndexPath.row) {
            case 1:
            {
                [_pageControlView setDisplayIndex:5 animated:NO];
            }
                break;
            case 2:
            {
                UIView * yellowColorHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
                yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
                _pageControlView.headerView = yellowColorHeaderView;
            }
                break;
            case 3:
            {
                UIView * yellowColorHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
                yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
                _pageControlView.headerView = yellowColorHeaderView;
                
                ThirdViewController * vc = [[ThirdViewController alloc] init];
                vc.title = @"测试pageControlView嵌套pageControlView";
                NSMutableArray * mChildControllers = [_pageControlView.childControllers mutableCopy];
                [mChildControllers insertObject:vc atIndex:1];
                
                [_pageControlView replaceChildControllers:mChildControllers];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.pageControlView setDisplayIndex:4 animated:YES completion:nil];
                });
            }
                break;
            case 4:
            {
                _pageControlView.bgScrollView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
                
                UIView * yellowColorHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
                yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
                _pageControlView.headerView = yellowColorHeaderView;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ExampleViewController * vc = [[ExampleViewController alloc] init];
                    vc.title = @"新controller";
                    NSMutableArray * childControllers = [self.pageControlView.childControllers mutableCopy];
                    [childControllers insertObject:vc atIndex:1];
                    [self.pageControlView replaceChildControllers:childControllers];
                });
            }
                break;
            default:
                break;
        }
    }
    return _pageControlView;
}

@end
