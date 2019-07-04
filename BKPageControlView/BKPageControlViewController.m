//
//  BKPageControlViewController.m
//  BKPageControlView
//
//  Created by zhaolin on 2019/7/3.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "BKPageControlViewController.h"

@interface BKPageControlViewController ()

@end

@implementation BKPageControlViewController

#pragma mark - viewDidLoad

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%lu,viewWillAppear", self.index);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%lu,viewDidAppear", self.index);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%lu,viewWillDisappear", self.index);
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"%lu,viewDidDisappear", self.index);
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"%lu,%@", self.index, NSStringFromCGRect(self.view.frame));
}

-(void)dealloc
{
    NSLog(@"%ld释放", self.index);
}

@end
