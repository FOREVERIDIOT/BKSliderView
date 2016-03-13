//
//  CustomSelectViewViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "CustomSelectViewViewController.h"
#import "BKSlideView.h"
#import "CustomSelectView.h"

@interface CustomSelectViewViewController ()<BKSlideViewDelegate,BKSlideMenuViewDelegate>
{
    BKSlideView * slideView;
    BKSlideMenuView * menuView;
}

@end

@implementation CustomSelectViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"自定义selectView界面";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];
    
    menuView = [[BKSlideMenuView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 45) menuTitleArray:titleArray];
    menuView.customDelegate = self;
    menuView.selectStyle = BKSlideMenuViewSelectStyleCustom | BKSlideMenuViewSelectStyleChangeColor;
    menuView.changeStyle = BKSlideMenuViewChangeStyleCenter;
    menuView.selectMenuTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    menuView.normalMenuTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [self.view addSubview:menuView];
    
    slideView = [[BKSlideView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(menuView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(menuView.frame)) allPageNum:[titleArray count]];
    slideView.customDelegate = self;
    [self.view addSubview:slideView];
}

#pragma mark - SlideViewDelegate

-(void)scrollSlideView:(BKSlideView *)theSlideView
{
    if ([theSlideView isEqual:slideView]) {
        [menuView scrollWith:theSlideView];
    }
}

-(void)endScrollSlideView:(BKSlideView *)theSlideView
{
    if ([theSlideView isEqual:slideView]) {
        [menuView endScrollWith:theSlideView];
    }
}

-(void)reuseCell:(UITableViewCell *)cell withIndex:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0f green:arc4random()%255/255.0f blue:arc4random()%255/255.0f alpha:1];
}

#pragma mark - SlideMenuViewDelegate

-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index
{
    [slideView rollSlideViewToIndexView:index];
}

// 自定义selectView
-(void)modifyChooseSelectView:(UIView *)selectView
{
    CustomSelectView * textView = [[CustomSelectView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [selectView addSubview:textView];
    
    CGPoint textViewCenter = textView.center;
    textViewCenter.y = selectView.center.y - selectView.frame.origin.y;
    textView.center = textViewCenter;
}

// 修改selectView移动时 selectView中自定义的View
-(void)changeElementInSelectView:(UIView *)selectView
{
    [[selectView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint viewCenter = obj.center;
        viewCenter.y = selectView.center.y - selectView.frame.origin.y;
        obj.center = viewCenter;
    }];
}

@end
