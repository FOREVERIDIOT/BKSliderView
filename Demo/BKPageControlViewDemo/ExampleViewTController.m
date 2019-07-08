//
//  ExampleViewTController.m
//  BKPageControlViewDemo
//
//  Created by zhaolin on 2019/7/8.
//  Copyright © 2019 BIKE. All rights reserved.
//

#import "ExampleViewTController.h"
#import "ExampleTableView.h"
#import "UIView+Extension.h"
#import <MJRefresh/MJRefresh.h>

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

@interface ExampleViewTController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) ExampleTableView * fTableView;
@property (nonatomic,strong) ExampleTableView * sTableView;
@property (nonatomic,strong) UIView * line;

@property (nonatomic,assign) NSUInteger fTotalCount;
@property (nonatomic,assign) NSUInteger sTotalCount;

@end

@implementation ExampleViewTController
@synthesize bk_index = _bk_index;
@synthesize bk_superVC = _bk_superVC;
@synthesize bk_mainScrollView = _bk_mainScrollView;

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fTotalCount = 5;
    self.sTotalCount = 20;
    
    [self.view addSubview:self.fTableView];
    [self.view addSubview:self.sTableView];
    [self.view addSubview:self.line];
}

//-(void)dealloc
//{
//    NSLog(@"释放ExampleViewTController");
//}

-(void)viewWillLayoutSubviews
{
    self.fTableView.frame = CGRectMake(0, 0, self.view.bk_width/2, self.view.bk_height);
    self.sTableView.frame = CGRectMake(CGRectGetMaxX(self.fTableView.frame), 0, self.view.bk_width - CGRectGetMaxX(self.fTableView.frame), self.view.bk_height);
    self.line.frame = CGRectMake(CGRectGetMaxX(self.fTableView.frame), 0, BK_ONE_PIXEL, self.view.bk_height);
}

#pragma mark - ExampleTableView

-(ExampleTableView*)fTableView
{
    if (!_fTableView) {
        _fTableView = [[ExampleTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        __weak typeof(self) weakSelf = self;
        [_fTableView setHitTestCallBack:^(CGPoint point) {
            weakSelf.bk_mainScrollView = weakSelf.fTableView;
        }];
        _fTableView.delegate = self;
        _fTableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _fTableView.estimatedRowHeight = 0;
            _fTableView.estimatedSectionFooterHeight = 0;
            _fTableView.estimatedSectionHeaderHeight = 0;
            _fTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _fTableView.tableFooterView = [UIView new];
        _fTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.fTableView.mj_footer endRefreshing];
                weakSelf.fTotalCount = weakSelf.fTotalCount + 10;
                [weakSelf.fTableView reloadData];
            });
        }];
    }
    return _fTableView;
}

-(ExampleTableView*)sTableView
{
    if (!_sTableView) {
        _sTableView = [[ExampleTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        __weak typeof(self) weakSelf = self;
        [_sTableView setHitTestCallBack:^(CGPoint point) {
            weakSelf.bk_mainScrollView = weakSelf.sTableView;
        }];
        _sTableView.delegate = self;
        _sTableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _sTableView.estimatedRowHeight = 0;
            _sTableView.estimatedSectionFooterHeight = 0;
            _sTableView.estimatedSectionHeaderHeight = 0;
            _sTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _sTableView.tableFooterView = [UIView new];
        _sTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.sTableView.mj_footer endRefreshing];
                weakSelf.sTotalCount = weakSelf.sTotalCount + 10;
                [weakSelf.sTableView reloadData];
            });
        }];
    }
    return _sTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fTableView == tableView) {
        return self.fTotalCount;
    }else {
        return self.sTotalCount;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - line

-(UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = [UIColor lightGrayColor];
    }
    return _line;
}

//#pragma mark - UIScrollViewDelegate
//
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (scrollView == self.fTableView) {
//        self.bk_mainScrollView = self.fTableView;
//    }else {
//        self.bk_mainScrollView = self.sTableView;
//    }
//}
//
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"5");
//}

@end
