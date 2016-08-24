//
//  BaseViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BaseViewController.h"
#import "BKSlideView.h"

@interface BaseViewController ()<BKSlideViewDelegate>
{
    BKSlideView * slideView;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"基本展示界面";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];
    
    slideView = [[BKSlideView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) menuTitleArray:titleArray delegate:self];
    [self.view addSubview:slideView];
}

#pragma mark - SlideViewDelegate

-(void)initInView:(UIView *)view atIndex:(NSInteger)index
{
    UIView * subView = [[UIView alloc]initWithFrame:view.bounds];
    subView.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0f green:(arc4random()%255)/255.0f blue:(arc4random()%255)/255.0f alpha:1];
    [view addSubview:subView];
}

@end
