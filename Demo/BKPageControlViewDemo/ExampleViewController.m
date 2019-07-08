//
//  ExampleViewController.m
//  BKPageControlView
//
//  Created by 兆林 on 2017/7/18.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "ExampleViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface ExampleViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,assign) NSUInteger totalCount;

@end

@implementation ExampleViewController
@synthesize bk_index = _bk_index;
@synthesize bk_superVC = _bk_superVC;
@synthesize bk_mainScrollView = _bk_mainScrollView;

-(void)setBk_index:(NSUInteger)bk_index
{
    _bk_index = bk_index;
    if (self.totalCount == 0) {
        self.totalCount = (_bk_index + 1) * 5;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

//-(void)dealloc
//{
//    NSLog(@"释放ExampleViewController");
//}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _tableView.frame = self.view.bounds;
    [_tableView reloadData];
}

#pragma mark - UITableView

-(UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.tableFooterView = [UIView new];
        __weak typeof(self) weakSelf = self;
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView.mj_footer endRefreshing];
                weakSelf.totalCount = weakSelf.totalCount + 10;
                [weakSelf.tableView reloadData];
            });
        }];
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.totalCount;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
