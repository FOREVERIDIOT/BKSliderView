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

@interface ViewController ()<BKSlideViewDelegate>
{
    BKSlideView * _slideView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"基本展示界面";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray * vcArray = [NSMutableArray array];
    for (int i = 0 ; i<10; i++) {
        ExampleViewController * vc = [[ExampleViewController alloc]init];
        vc.title = [NSString stringWithFormat:@"第%d个",i];
        [vcArray addObject:vc];
    }
    
    _slideView = [[BKSlideView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) vcArray:vcArray];
    _slideView.delegate = self;
    [self.view addSubview:_slideView];
    
    UIView * yellowColorHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    yellowColorHeaderView.backgroundColor = [UIColor yellowColor];
    _slideView.headerView = yellowColorHeaderView;
}

-(void)slideView:(BKSlideView*)slideView createVCWithIndex:(NSInteger)index
{
    ExampleViewController * vc = _slideView.vcArray[index];
    [vc createUIWithIndex:index];
}

@end
