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
#import "UIView+Extension.h"

@interface FirstViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    
    [self.view addSubview:self.tableView];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _tableView.frame = CGRectMake(0, get_system_nav_height(), self.view.bk_width, self.view.bk_height - get_system_nav_height());
}

#pragma mark - UITableView

-(UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, get_system_nav_height(), self.view.bk_width, self.view.bk_height - get_system_nav_height()) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"基本演示Demo";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"开始选中第5个演示Demo";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"带headerView演示Demo";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"嵌套pageControlView演示Demo";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"2s后插入新controller演示Demo";
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SecondViewController * vc = [[SecondViewController alloc] init];
    vc.selectIndexPath = indexPath;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
