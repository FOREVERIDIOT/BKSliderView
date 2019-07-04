//
//  FirstViewController.m
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/3.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "Inline.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    
    UIButton * exampleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exampleBtn.frame = CGRectMake(0, get_system_nav_height(), self.view.frame.size.width, self.view.frame.size.height - get_system_nav_height());
    [exampleBtn setTitle:@"例子" forState:UIControlStateNormal];
    [exampleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    exampleBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [exampleBtn addTarget:self action:@selector(exampleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exampleBtn];
}

-(void)exampleBtnClick
{
    SecondViewController * vc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
