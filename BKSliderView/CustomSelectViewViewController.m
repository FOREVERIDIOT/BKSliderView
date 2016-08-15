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
    BKSlideView * theSlideView;
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
    menuView.slideMenuViewSelectStyle = SlideMenuViewSelectStyleCustom | SlideMenuViewSelectStyleChangeColor;
    menuView.slideMenuViewChangeStyle = SlideMenuViewChangeStyleCenter;
    menuView.selectMenuTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    menuView.normalMenuTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
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

// 自定义selectView
-(void)modifyChooseSelectView:(UIView *)selectView
{
    CustomSelectView * textView = [[CustomSelectView alloc]initWithFrame:CGRectMake(0, selectView.frame.size.height - 10, 10, 10)];
    [selectView addSubview:textView];
    
    CGPoint textViewCenter = textView.center;
    textViewCenter.x = selectView.center.x - selectView.frame.origin.x;
    textView.center = textViewCenter;
}

// 修改selectView移动时 selectView中自定义的View
-(void)changeElementInSelectView:(UIView *)selectView
{
    [[selectView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint viewCenter = obj.center;
        viewCenter.x = selectView.center.x - selectView.frame.origin.x;
        viewCenter.y = obj.center.y;
        obj.center = viewCenter;
    }];
}

@end
