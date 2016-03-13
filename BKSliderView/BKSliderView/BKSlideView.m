//
//  BKSlideView.m
//
//  Created on 16/2/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKSlideView.h"

@interface BKSlideView()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation BKSlideView
@synthesize pageNum = _pageNum;

-(instancetype)initWithFrame:(CGRect)frame allPageNum:(NSInteger)pageNum
{
    self = [super initWithFrame:CGRectMake((frame.size.width-frame.size.height)/2.0f+frame.origin.x, (frame.size.height-frame.size.width)/2.0f+frame.origin.y, frame.size.height, frame.size.width) style:UITableViewStylePlain];
    
    if (self) {
        
        _pageNum = pageNum;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.delegate = self;
        self.dataSource = self;
        self.tableFooterView = [UIView new];
        self.pagingEnabled = YES;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pageNum;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"SlideTableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        if ([self.customDelegate respondsToSelector:@selector(initCell:withIndex:)]) {
            [self.customDelegate initCell:cell withIndex:indexPath];
        }
    }
    
    if ([self.customDelegate respondsToSelector:@selector(reuseCell:withIndex:)]) {
        [self.customDelegate reuseCell:cell withIndex:indexPath];
    }
    
    cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.width;
}

#pragma mark - UIScrollDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        if ([self.customDelegate respondsToSelector:@selector(scrollSlideView:)]) {
            [self.customDelegate scrollSlideView:self];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        if ([self.customDelegate respondsToSelector:@selector(endScrollSlideView:)]) {
            [self.customDelegate endScrollSlideView:self];
        }
    }
}

/**
 *     移动 SlideView 至第 index 页
 **/
-(void)rollSlideViewToIndexView:(NSInteger)index
{
    CGFloat rollLength = self.frame.size.width*index;
    
    [self setContentOffset:CGPointMake(0, rollLength) animated:NO];
}

@end
