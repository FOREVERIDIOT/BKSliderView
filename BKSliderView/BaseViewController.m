//
//  BaseViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BaseViewController.h"
#import "BKSlideView.h"

@interface BaseViewController ()<BKSlideViewDelegate,BKSlideMenuViewDelegate>
{
    BKSlideView * theSlideView;
    BKSlideMenuView * menuView;
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
    
    menuView = [[BKSlideMenuView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 45) menuTitleArray:titleArray];
    menuView.customDelegate = self;
    [self.view addSubview:menuView];
    
    theSlideView = [[BKSlideView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(menuView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(menuView.frame)) allPageNum:[titleArray count] delegate:self];
    theSlideView.customDelegate = self;
    [self.view addSubview:theSlideView];
}

#pragma mark - SlideViewDelegate

-(void)scrollSlideView:(UICollectionView *)slideView
{
    if ([theSlideView.slideView isEqual:slideView]) {
        [menuView scrollWith:theSlideView.slideView];
    }
}

-(void)endScrollSlideView:(UICollectionView *)slideView
{
    if ([theSlideView.slideView isEqual:slideView]) {
        [menuView endScrollWith:theSlideView.slideView];
    }
}

-(void)initInView:(UIView *)view atIndex:(NSInteger)index
{
    UIView * subView = [[UIView alloc]initWithFrame:view.bounds];
    subView.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0f green:(arc4random()%255)/255.0f blue:(arc4random()%255)/255.0f alpha:1];
    [view addSubview:subView];
}

#pragma mark - SlideMenuViewDelegate

-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index
{
    [theSlideView rollSlideViewToIndexView:index];
}


@end
