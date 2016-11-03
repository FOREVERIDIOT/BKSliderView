//
//  ViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "ViewController.h"
#import "BKSlideView.h"

@interface ViewController ()
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
        UIViewController * vc = [[UIViewController alloc]init];
        vc.title = [NSString stringWithFormat:@"第%d个",i];
        vc.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0f green:arc4random()%255/255.0f blue:arc4random()%255/255.0f alpha:1];
        [vcArray addObject:vc];
    }
    
    _slideView = [[BKSlideView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) vcArray:vcArray];
    _slideView.slideMenuViewChangeStyle = SlideMenuViewChangeStyleCenter;
    [self.view addSubview:_slideView];
}

@end
