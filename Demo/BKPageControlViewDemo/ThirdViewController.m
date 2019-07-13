//
//  ThirdViewController.m
//  BKPageControlViewDemo
//
//  Created by zhaolin on 2019/7/5.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "ThirdViewController.h"
#import "Inline.h"
#import "UIView+Extension.h"
#import "ExampleViewController.h"

@interface ThirdViewController ()

@property (nonatomic,strong) BKPageControlView * pageControlView;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray * viewControllers = [NSMutableArray array];
    for (int i = 0 ; i < 5; i++) {
        ExampleViewController * vc = [[ExampleViewController alloc] init];
        vc.title = [NSString stringWithFormat:@"第%d个",i];
        [viewControllers addObject:vc];
    }
    
    self.pageControlView = [[BKPageControlView alloc] initWithFrame:CGRectZero childControllers:viewControllers superVC:self];
    self.pageControlView.useCsPanGestureOnCollectionView = YES;
    [self.view addSubview:self.pageControlView];
    
    UIView * redColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    redColorHeaderView.backgroundColor = [UIColor redColor];
    self.pageControlView.headerView = redColorHeaderView;
}

//-(void)dealloc
//{
//    NSLog(@"释放ThirdViewController");
//}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.pageControlView.frame = CGRectMake(0, 0, self.view.bk_width, self.view.bk_height);
    self.pageControlView.menuView.menuEqualDivisionW = self.pageControlView.bk_width / [self.pageControlView.childControllers count];
}

@end
