//
//  ExampleViewController.m
//  BKSliderExample
//
//  Created by 毕珂 on 16/3/6.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "ExampleViewController.h"
#import "BKSlideView.h"

typedef enum {
    ExampleView_ExampleTableView_Tag = 100,
    ExampleView_ExampleTableView_HeaderLoadLab_Tag,
    ExampleView_ExampleTableView_FooterLoadLab_Tag
}ExampleTag;

@interface ExampleViewController ()<BKSlideViewDelegate,BKSlideMenuViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BKSlideView * slideView;
    BKSlideMenuView * menuView;
    
    NSMutableDictionary * dataDic;
    NSInteger num;
    
    BOOL isRefresh;
}

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"example界面";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];
    
    dataDic = [NSMutableDictionary dictionary];
    [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dataDic setObject:@[@"0",@"1",@"2"] forKey:[NSString stringWithFormat:@"%ld",idx]];
    }];
    
    menuView = [[BKSlideMenuView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 45) menuTitleArray:titleArray];
    menuView.customDelegate = self;
    menuView.selectStyle = BKSlideMenuViewSelectStyleChangeFont | BKSlideMenuViewSelectStyleChangeColor;
    menuView.changeStyle = BKSlideMenuViewChangeStyleCenter;
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

-(void)initCell:(UITableViewCell *)cell withIndex:(NSIndexPath *)indexPath
{
    UITableView * exampleTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, slideView.frame.size.height) style:UITableViewStylePlain];
    exampleTableView.delegate = self;
    exampleTableView.dataSource = self;
    exampleTableView.showsVerticalScrollIndicator = NO;
    exampleTableView.backgroundColor = [UIColor clearColor];
    exampleTableView.tag = ExampleView_ExampleTableView_Tag;
    [cell addSubview:exampleTableView];
    
    exampleTableView.tableFooterView = [UIView new];

    UILabel * headerLoadLab = [[UILabel alloc]initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
    headerLoadLab.textAlignment = NSTextAlignmentCenter;
    headerLoadLab.font = [UIFont systemFontOfSize:15];
    headerLoadLab.tag = ExampleView_ExampleTableView_HeaderLoadLab_Tag;
    [exampleTableView addSubview:headerLoadLab];
    
    UILabel * footerLoadLab = [[UILabel alloc]initWithFrame:CGRectMake(0, exampleTableView.contentSize.height, self.view.frame.size.width, 40)];
    footerLoadLab.textAlignment = NSTextAlignmentCenter;
    footerLoadLab.font = [UIFont systemFontOfSize:15];
    footerLoadLab.tag = ExampleView_ExampleTableView_FooterLoadLab_Tag;

    exampleTableView.tableFooterView = footerLoadLab;
}

-(void)reuseCell:(UITableViewCell *)cell withIndex:(NSIndexPath *)indexPath
{
    UITableView * exampleTableView = (UITableView*)[cell viewWithTag:ExampleView_ExampleTableView_Tag];
    NSString * indexStr = [NSString stringWithFormat:@"%ld",indexPath.row];
    num = [indexStr integerValue];
    
    UILabel * headerLoadLab = (UILabel*)[exampleTableView viewWithTag:ExampleView_ExampleTableView_HeaderLoadLab_Tag];
    UILabel * footerLoadLab =  (UILabel*)[exampleTableView viewWithTag:ExampleView_ExampleTableView_FooterLoadLab_Tag];
    headerLoadLab.text = @"下拉加载更多";
    footerLoadLab.text = @"上拉加载更多";

    [exampleTableView reloadData];
}

#pragma mark - SlideMenuViewDelegate

-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index
{
    [slideView rollSlideViewToIndexView:index];
}


#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataDic[[NSString stringWithFormat:@"%ld",num]] count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"example";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    NSString * numStr = [NSString stringWithFormat:@"%ld",num];
    cell.textLabel.text = [NSString stringWithFormat:@"第%@行",dataDic[numStr][indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// 以下是上拉、下拉 加载更多 可以用自己的上拉加载 下拉刷新
#pragma mark - UIScrollDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isRefresh) {
        return;
    }
    
    UITableViewCell * cell = [slideView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:num inSection:0]];
    UITableView * exampleTableView = (UITableView*)[cell viewWithTag:ExampleView_ExampleTableView_Tag];
    UILabel * headerLoadLab = (UILabel*)[exampleTableView viewWithTag:ExampleView_ExampleTableView_HeaderLoadLab_Tag];
    UILabel * footerLoadLab =  (UILabel*)[exampleTableView viewWithTag:ExampleView_ExampleTableView_FooterLoadLab_Tag];
    
    if ([scrollView isEqual:exampleTableView]) {
        if (exampleTableView.contentSize.height > exampleTableView.frame.size.height) {
            if (exampleTableView.contentOffset.y + exampleTableView.frame.size.height > exampleTableView.contentSize.height) {
                footerLoadLab.text = @"加载中";
                [self changeTextUIOnView:exampleTableView WithloadLab:footerLoadLab direction:@"footer"];
            }else if (exampleTableView.contentOffset.y < -40) {
                headerLoadLab.text = @"加载中";
                [self changeTextUIOnView:exampleTableView WithloadLab:headerLoadLab direction:@"header"];
            }else{
                headerLoadLab.text = @"下拉加载更多";
                footerLoadLab.text = @"上拉加载更多";
            }
        }else{
            if (exampleTableView.contentOffset.y > 40) {
                footerLoadLab.text = @"加载中";
                [self changeTextUIOnView:exampleTableView WithloadLab:footerLoadLab direction:@"footer"];
            }else if (exampleTableView.contentOffset.y < -40) {
                headerLoadLab.text = @"加载中";
                [self changeTextUIOnView:exampleTableView WithloadLab:headerLoadLab direction:@"header"];
            }else{
                headerLoadLab.text = @"下拉加载更多";
                footerLoadLab.text = @"上拉加载更多";
            }
        }
    }
}

-(void)changeTextUIOnView:(UIView*)view WithloadLab:(UILabel*)label direction:(NSString*)direction
{
    if (isRefresh) {
        return;
    }
    isRefresh = YES;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        for (int i = 1; i < 4; i++) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i*0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                label.text = [NSString stringWithFormat:@"加载中%@",[self appendDotWithDotNum:i]];
                
                if (i == 3) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        isRefresh = NO;
                        UITableView * exampleTableView = (UITableView*)view;
                        NSString * numStr = [NSString stringWithFormat:@"%ld",num];
                        NSMutableArray * dataArr = [NSMutableArray arrayWithArray:dataDic[numStr]];
                        if ([direction isEqualToString:@"header"]) {
                            label.text = @"下拉加载更多";
                            [dataArr insertObject:[NSString stringWithFormat:@"%ld",[dataArr count]] atIndex:0];
                            [dataDic setObject:dataArr forKey:numStr];
                            [exampleTableView reloadData];
                        }else if ([direction isEqualToString:@"footer"]) {
                            label.text = @"上拉加载更多";
                            [dataArr insertObject:[NSString stringWithFormat:@"%ld",[dataArr count]] atIndex:[dataArr count]];
                            [dataDic setObject:dataArr forKey:numStr];
                            [exampleTableView reloadData];
                        }
                    });
                }
            });
        }
    });
}

-(NSString*)appendDotWithDotNum:(NSInteger)dotNum
{
    NSMutableString * appendStr = [NSMutableString string];
    for (int i = 0; i < dotNum; i++) {
        [appendStr appendString:@"."];
    }
    return appendStr;
}

@end
