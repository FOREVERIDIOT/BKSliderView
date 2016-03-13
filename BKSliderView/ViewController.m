//
//  ViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "ViewController.h"
#import "BaseViewController.h"
#import "CustomSelectViewViewController.h"
#import "ExampleViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"首页";
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)baseBtnClick:(id)sender
{
    BaseViewController * VC = [[BaseViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)customSelectViewBtnClick:(id)sender
{
    CustomSelectViewViewController * VC = [[CustomSelectViewViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)exampleBtnClick:(id)sender
{
    ExampleViewController * VC = [[ExampleViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

@end
