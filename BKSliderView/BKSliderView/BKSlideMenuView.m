//
//  BKSlideMenuView.m
//
//  Created on 16/2/3.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define NORMAL_TITLE_FONT 14.0f
#define SELECT_TITLE_FONT 16.0f
#define NORMAL_TITLE_COLOR [UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:0.6]
#define SELECT_TITLE_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define Left_RIGHT_GAP 20.0f
#define MENU_TITLE_WIDTH 100.0f

#import "BKSlideMenuView.h"
#import "BKSlideView.h"

typedef enum {
    BKSlideMenuViewCell_tilteLab_tag = 100,
}BKSlideMenuViewCellTag;

@interface BKSlideMenuView()<UITableViewDataSource,UITableViewDelegate>
{
//    点击
//    判断是否是点击事件
    BOOL isMenuTapFlag;
//    点击 menu 的index
    NSInteger tapIndex;
//    上一次点击的 menu 的index
    NSInteger oldTapIndex;
//    上一次点击的 menu
    UILabel * oldSelectLab;
    
//    滑动
//    SlideView 移动的距离
    CGFloat moveLength;
//    是否滑动中
    BOOL isScrollFlag;
//    滑动 fromIndex
    NSInteger scroll_fromIndex;
//    滑动 toIndex
    NSInteger scroll_toIndex;
    
//    自定义selectView
//    是否自定义selectView
    BOOL isCustomSelectView;
}

//    menu title font 数组
@property (nonatomic,strong) NSMutableArray * menuTitleZoomArr;
//    menu title color 数组
@property (nonatomic,strong) NSMutableArray * menuTitleColorArr;

@end

@implementation BKSlideMenuView
@synthesize menuTitleArray = _menuTitleArray;
@synthesize rowHeightArr = _rowHeightArr;
@synthesize rowYArr = _rowYArr;

#pragma mark - 字体

-(void)setNormalMenuTitleFont:(UIFont *)normalMenuTitleFont
{
    _normalMenuTitleFont = normalMenuTitleFont;
    [self initMenuTitleFontArrWithNormalFont:normalMenuTitleFont selectFont:_selectMenuTitleFont];
}

-(void)setSelectMenuTitleFont:(UIFont *)selectMenuTitleFont
{
    _selectMenuTitleFont = selectMenuTitleFont;
    [self initMenuTitleFontArrWithNormalFont:_normalMenuTitleFont selectFont:selectMenuTitleFont];
}

-(void)initMenuTitleFontArrWithNormalFont:(UIFont*)normalMenuTitleFont selectFont:(UIFont*)selectMenuTitleFont
{
    if (!_menuTitleZoomArr) {
        _menuTitleZoomArr = [NSMutableArray array];
        [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                CGFloat fontMagnifyGap = _selectMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize;
                [_menuTitleZoomArr addObject:[NSString stringWithFormat:@"%f",fontMagnifyGap]];
            }else{
                CGFloat fontGap = _normalMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize;
                [_menuTitleZoomArr addObject:[NSString stringWithFormat:@"%f",fontGap]];
            }
        }];
    }else{
        
        if (_selectStyle & BKSlideMenuViewSelectStyleChangeFont) {
            CGFloat fontMagnifyGap = selectMenuTitleFont.pointSize / normalMenuTitleFont.pointSize;
            CGFloat fontGap = normalMenuTitleFont.pointSize / normalMenuTitleFont.pointSize;
            
            [_menuTitleZoomArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_menuTitleZoomArr replaceObjectAtIndex:idx withObject:[NSString stringWithFormat:@"%f",fontGap]];
                if (idx == oldTapIndex) {
                    [_menuTitleZoomArr replaceObjectAtIndex:idx withObject:[NSString stringWithFormat:@"%f",fontMagnifyGap]];
                }
            }];
        }
    }
}

#pragma mark - 颜色

-(void)setNormalMenuTitleColor:(UIColor *)normalMenuTitleColor
{
    _normalMenuTitleColor = normalMenuTitleColor;
    [self initMenuTitleColorArrWithNormalColor:normalMenuTitleColor selectColor:_selectMenuTitleColor];
}

-(void)setSelectMenuTitleColor:(UIColor *)selectMenuTitleColor
{
    _selectMenuTitleColor = selectMenuTitleColor;
    [self initMenuTitleColorArrWithNormalColor:_normalMenuTitleColor selectColor:selectMenuTitleColor];
}

-(void)initMenuTitleColorArrWithNormalColor:(UIColor*)normalMenuTitleColor selectColor:(UIColor*)selectMenuTitleColor
{
    if (!_menuTitleColorArr) {
        _menuTitleColorArr = [NSMutableArray array];
        [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [_menuTitleColorArr addObject:selectMenuTitleColor];
            }else{
                [_menuTitleColorArr addObject:normalMenuTitleColor];
            }
        }];
    }else{
        
        if (_selectStyle & BKSlideMenuViewSelectStyleChangeColor) {
            [_menuTitleColorArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_menuTitleColorArr replaceObjectAtIndex:idx withObject:normalMenuTitleColor];
                if (idx == oldTapIndex) {
                    [_menuTitleColorArr replaceObjectAtIndex:idx withObject:selectMenuTitleColor];
                }
            }];
        }
    }
}

#pragma mark - menuTitle 距离

-(void)setTitleWidthStyle:(BKSlideMenuViewTitleWidthStyle)titleWidthStyle
{
    _titleWidthStyle = titleWidthStyle;
    
    NSMutableArray * heightArr = [NSMutableArray array];
    __block CGFloat Y = 0;
    NSMutableArray * YArr = [NSMutableArray array];
    [_menuTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [YArr addObject:[NSString stringWithFormat:@"%f",Y]];
        
        CGFloat width = 0;
        switch (titleWidthStyle) {
            case BKSlideMenuViewTitleWidthStyleDefault:
            {
                _menuTitleLength = Left_RIGHT_GAP;
                
                NSString * string = obj;
                CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT,self.frame.size.height)
                                                   options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:_normalMenuTitleFont}
                                                   context:nil];
                width = rect.size.width+_menuTitleLength;
            }
                break;
            case BKSlideMenuViewTitleWidthStyleSame:
            {
                _menuTitleLength = MENU_TITLE_WIDTH;
                width = _menuTitleLength;
            }
                break;
            default:
                break;
        }
        
        [heightArr addObject:[NSString stringWithFormat:@"%f",width]];
        
        Y = Y + width;
    }];
    _rowHeightArr = heightArr;
    _rowYArr = YArr;
    
    _selectView.frame = CGRectMake(0,0,2,[_rowHeightArr[0] floatValue]);
    
}

-(void)setMenuTitleLength:(CGFloat)menuTitleLength
{
    CGFloat gap = menuTitleLength - _menuTitleLength;
    
    _menuTitleLength = menuTitleLength;
    
    NSMutableArray * heightArr = [NSMutableArray arrayWithArray:_rowHeightArr];
    __block CGFloat Y = 0;
    NSMutableArray * YArr = [NSMutableArray array];
    [heightArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [YArr addObject:[NSString stringWithFormat:@"%f",Y]];
        
        switch (_titleWidthStyle) {
            case BKSlideMenuViewTitleWidthStyleDefault:
            {
                [heightArr replaceObjectAtIndex:idx withObject:[NSString stringWithFormat:@"%f",[obj floatValue]+gap]];
                
                Y = Y + [obj floatValue] + gap;
            }
                break;
            case BKSlideMenuViewTitleWidthStyleSame:
            {
                [heightArr replaceObjectAtIndex:idx withObject:[NSString stringWithFormat:@"%f",menuTitleLength]];
                
                Y = Y + menuTitleLength;
            }
                break;
            default:
                break;
        }
    }];
    
    _rowHeightArr = heightArr;
    _rowYArr = YArr;
    
    _selectView.frame = CGRectMake(0,0,2,[_rowHeightArr[0] floatValue]);
}

#pragma mark - 初始

-(instancetype)initWithFrame:(CGRect)frame menuTitleArray:(NSArray*)titleArray
{
    self = [super initWithFrame:CGRectMake((frame.size.width-frame.size.height)/2.0f+frame.origin.x, (frame.size.height-frame.size.width)/2.0f+frame.origin.y, frame.size.height, frame.size.width) style:UITableViewStylePlain];
    
    if (self) {
        
        _menuTitleArray = titleArray;
        
        [self initData];
        [self initSelfProperty];
        
        if (!self.customDelegate) {
            [self initSelectView];
        }
    }
    return self;
}

-(void)initData
{
    moveLength = 0;
    
    _normalMenuTitleFont = [UIFont systemFontOfSize:NORMAL_TITLE_FONT];
    _selectMenuTitleFont = [UIFont systemFontOfSize:SELECT_TITLE_FONT];
    [self initMenuTitleFontArrWithNormalFont:_normalMenuTitleFont selectFont:_selectMenuTitleFont];
    
    _normalMenuTitleColor = NORMAL_TITLE_COLOR;
    _selectMenuTitleColor = SELECT_TITLE_COLOR;
    [self initMenuTitleColorArrWithNormalColor:_normalMenuTitleColor selectColor:_selectMenuTitleColor];
    
    self.titleWidthStyle = BKSlideMenuViewTitleWidthStyleDefault;
}

-(void)initSelectView
{
    _selectStyle = BKSlideMenuViewSelectStyleHaveLine | BKSlideMenuViewSelectStyleChangeFont | BKSlideMenuViewSelectStyleChangeColor;
    
    _selectView = [[UIView alloc]initWithFrame:CGRectMake(0,0,2,[_rowHeightArr[0] floatValue])];
    _selectView.backgroundColor = [UIColor blackColor];
    _selectView.layer.cornerRadius = _selectView.bounds.size.width/2.0f;
    _selectView.clipsToBounds = YES;
    [self addSubview:_selectView];
}

-(void)initSelfProperty
{
    self.backgroundColor = [UIColor whiteColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    self.delegate = self;
    self.dataSource = self;
    self.tableFooterView = [UIView new];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuTitleArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"SlideMenuTableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.tag = BKSlideMenuViewCell_tilteLab_tag;
        [cell addSubview:titleLab];
    }
    
    UILabel * titleLab = (UILabel*)[cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
    CGRect titleLabFrame = titleLab.frame;
    titleLabFrame.origin.x = 0;
    titleLabFrame.size.width = [_rowHeightArr[indexPath.row] floatValue];
    titleLab.frame = titleLabFrame;
    titleLab.font = _normalMenuTitleFont;
    titleLab.transform = CGAffineTransformMakeScale([_menuTitleZoomArr[indexPath.row] floatValue], [_menuTitleZoomArr[indexPath.row] floatValue]);
    titleLab.text = _menuTitleArray[indexPath.row];
    titleLab.textColor = _menuTitleColorArr[indexPath.row];
    
    if (!oldSelectLab) {
        oldSelectLab = titleLab;
        oldTapIndex = 0;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_rowHeightArr[indexPath.row] floatValue];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isMenuTapFlag = YES;
    tapIndex = indexPath.row;
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    CGRect selectViewFrame = _selectView.frame;
    selectViewFrame.origin.y = cell.frame.origin.y;
    selectViewFrame.size.height = [_rowHeightArr[indexPath.row] floatValue];
    
    if ([self.customDelegate respondsToSelector:@selector(selectMenuSlide:relativelyViewWithViewIndex:)]) {
        [self.customDelegate selectMenuSlide:self relativelyViewWithViewIndex:indexPath.row];
    }
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _selectView.frame = selectViewFrame;
    } completion:^(BOOL finished) {
        isMenuTapFlag = NO;
    }];
}

#pragma mark - 自定义selectView

-(void)setSelectStyle:(BKSlideMenuViewSelectStyle)selectStyle
{
    _selectStyle = selectStyle;
    
    if (_selectStyle & BKSlideMenuViewSelectStyleChangeFont) {

    }else{
        [_menuTitleZoomArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_menuTitleZoomArr replaceObjectAtIndex:idx withObject:@"1"];
            
            if (idx == [_menuTitleZoomArr count]-1) {
                [self reloadData];
            }
        }];
    }
    
    if (_selectStyle & BKSlideMenuViewSelectStyleChangeColor) {
        
    }else{
        [_menuTitleColorArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_menuTitleColorArr replaceObjectAtIndex:idx withObject:_normalMenuTitleColor];
            
            if (idx == [_menuTitleColorArr count]-1) {
                [self reloadData];
            }
        }];
    }
 
    if (selectStyle & BKSlideMenuViewSelectStyleHaveLine) {
        
    }else{
        _selectView.frame = CGRectMake(0, 0, self.frame.size.height, [_rowHeightArr[0] floatValue]);
        _selectView.backgroundColor = [UIColor clearColor];
        _selectView.layer.cornerRadius = 0;
        _selectView.clipsToBounds = NO;
        
        if (selectStyle & BKSlideMenuViewSelectStyleCustom) {
            [self refreshChangeSelectView];
        }
    }
}

-(void)refreshChangeSelectView
{
    if ([self.customDelegate respondsToSelector:@selector(modifyChooseSelectView:)]) {
        [self.customDelegate modifyChooseSelectView:_selectView];
    }
    
    [_selectView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    isCustomSelectView = YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isEqual:_selectView]) {
        if ([self.customDelegate respondsToSelector:@selector(changeElementInSelectView:)]) {
            [self.customDelegate changeElementInSelectView:_selectView];
        }
    }
}

-(void)dealloc
{
    if (isCustomSelectView) {
        [_selectView removeObserver:self forKeyPath:@"frame"];
    }
}

#pragma mark - selectView 滑动动画

/**
 *     随着 SlideView 滑动的距离滑动
 **/
-(void)scrollWith:(BKSlideView*)slideView
{
    if (_selectStyle == BKSlideMenuViewSelectStyleNone) {
        return;
    }
    
    if (isMenuTapFlag) {
        moveLength = slideView.contentOffset.y;
        
//    更改选中title 样式
        if (_selectStyle & BKSlideMenuViewSelectStyleChangeFont) {
            [self cellTitleLabFontMagnifyWithNewIndex:tapIndex];
        }
        
        if (_selectStyle & BKSlideMenuViewSelectStyleChangeColor) {
            [self cellTitleChangeColorWithNewIndex:tapIndex];
        }
        
//    ********************************************
//    更换旧的选中title
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:tapIndex inSection:0];
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        
        UILabel * titleLab = (UILabel*)[cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
        
        oldSelectLab = titleLab;
        oldTapIndex = tapIndex;
        
//    ********************************************
        
        if (self.contentSize.height > self.frame.size.width) {
            [self tapChangeIndex:tapIndex animation:self.changeStyle];
        }
        
        return;
    }
    
    moveLength = moveLength - slideView.contentOffset.y;
    
//    ********************************************
//    取得 toIndex & fromIndex
    
    NSInteger toIndex = 0;
    NSInteger fromIndex = 0;
    if (slideView.contentOffset.y <= 0 || slideView.contentOffset.y >= slideView.contentSize.height - slideView.frame.size.width) {
        if (slideView.contentOffset.y <= 0) {
            fromIndex = 0;
            toIndex = 0;
        }
        
        if (slideView.contentOffset.y >= slideView.contentSize.height - slideView.frame.size.width) {
            toIndex = [_rowHeightArr count] - 1;
            fromIndex = [_rowHeightArr count] - 1;
        }

    }else{
        NSInteger selectIndex = [[NSString stringWithFormat:@"%f",slideView.contentOffset.y/slideView.frame.size.width] integerValue];
        
        NSString * contentOffsetY = [NSString stringWithFormat:@"%f",slideView.contentOffset.y];
        NSString * width = [NSString stringWithFormat:@"%f",slideView.frame.size.width];
        
        NSInteger yPointLoction;
        if ([contentOffsetY rangeOfString:@"."].location != NSNotFound) {
            yPointLoction = [contentOffsetY rangeOfString:@"."].location;
        }
        
        NSInteger widthPointLoction;
        if ([width rangeOfString:@"."].location != NSNotFound) {
            widthPointLoction = [width rangeOfString:@"."].location;
        }
        
        NSInteger pointLaterLength = [contentOffsetY length]-yPointLoction>[width length]-widthPointLoction?[contentOffsetY length]-yPointLoction:[width length]-widthPointLoction;
        
        NSInteger contentOffsetY_integer = slideView.contentOffset.y * pow(10, pointLaterLength);
        NSInteger width_integer = slideView.frame.size.width * pow(10, pointLaterLength);
        
        if (moveLength>0) {
            toIndex = selectIndex;
            fromIndex = selectIndex + 1;
        }else if (moveLength<0) {
            fromIndex = selectIndex;
            toIndex = selectIndex + 1;
        }
        
        if (contentOffsetY_integer % width_integer == 0) {
            if (moveLength<0) {
                fromIndex = selectIndex - 1;
                toIndex = selectIndex;
            }
        }
    }
    
//    ********************************************
//    防止滑动过快 字体 颜色 长度 变形
    [self preventDeformationWithScrollView:slideView fromCellIndex:fromIndex toCellIndex:toIndex];
//    ********************************************
    
    if (self.contentSize.height > self.frame.size.width) {
//    动画格式 并且改变 self contentOffset.y距离
        [self moveChangeAnimation:self.changeStyle];
    }
    
//    改变selectView滑动位置
    [self selectViewChangeWithScrollView:slideView fromCellIndex:fromIndex toCellIndex:toIndex move:moveLength];
    
    if (_selectStyle & BKSlideMenuViewSelectStyleChangeFont) {
//    改变滑动中 即将取消选择 和 选择的 cell 字号
        [self scrollSlideViewMagnifyFontWithFromCellIndex:fromIndex toCellIndex:toIndex scrollView:slideView];
    }
    
    if (_selectStyle & BKSlideMenuViewSelectStyleChangeColor) {
//    改变滑动中 即将取消选择 和 选择的 cell 字体颜色
        [self scrollSlideViewChangeSelectColorWithFromCellIndex:fromIndex toCellIndex:toIndex scrollView:slideView];
    }
    
    moveLength = slideView.contentOffset.y;
}

/**
 *     防止滑动过快 字体 颜色 长度 变形
 **/
-(void)preventDeformationWithScrollView:(BKSlideView*)slideView fromCellIndex:(NSInteger)fromIndex toCellIndex:(NSInteger)toIndex
{
    if (!isScrollFlag) {
        isScrollFlag = YES;
        
        scroll_fromIndex = fromIndex;
        scroll_toIndex = toIndex;
    }else{
        if (scroll_toIndex != fromIndex && scroll_toIndex != toIndex && scroll_fromIndex == fromIndex) {
            
            NSIndexPath * from_indexPath = [NSIndexPath indexPathForRow:scroll_fromIndex inSection:0];
            NSIndexPath * to_indexPath = [NSIndexPath indexPathForRow:scroll_toIndex inSection:0];
            UITableViewCell * from_cell = [self cellForRowAtIndexPath:from_indexPath];
            UITableViewCell * to_cell = [self cellForRowAtIndexPath:to_indexPath];
            
            UILabel * from_titleLab = (UILabel*)[from_cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            UILabel * to_titleLab = (UILabel*)[to_cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            
            if (_selectStyle & BKSlideMenuViewSelectStyleChangeFont) {
                CGFloat fontGap = _selectMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize;
                from_titleLab.transform = CGAffineTransformMakeScale(fontGap, fontGap);
                to_titleLab.transform = CGAffineTransformMakeScale(1, 1);
                [_menuTitleZoomArr replaceObjectAtIndex:scroll_fromIndex withObject:[NSString stringWithFormat:@"%f",fontGap]];
                [_menuTitleZoomArr replaceObjectAtIndex:scroll_toIndex withObject:@"1"];
            }
            
            if (_selectStyle & BKSlideMenuViewSelectStyleChangeColor) {
                from_titleLab.textColor = _selectMenuTitleColor;
                to_titleLab.textColor = _normalMenuTitleColor;
                [_menuTitleColorArr replaceObjectAtIndex:scroll_fromIndex withObject:_selectMenuTitleColor];
                [_menuTitleColorArr replaceObjectAtIndex:scroll_toIndex withObject:_normalMenuTitleColor];
            }
            
            CGFloat cellHeight = [_rowHeightArr[scroll_fromIndex] floatValue];
            CGFloat cellY = [_rowYArr[scroll_fromIndex] floatValue];
            
            CGRect selectViewFrame = _selectView.frame;
            selectViewFrame.size.height = cellHeight;
            selectViewFrame.origin.y = cellY;
            _selectView.frame = selectViewFrame;
            
            scroll_fromIndex = fromIndex;
            scroll_toIndex = toIndex;
        }
    }
}

/**
 *     selectView 改变滑动位置
 **/
-(void)selectViewChangeWithScrollView:(BKSlideView*)slideView fromCellIndex:(NSInteger)fromIndex toCellIndex:(NSInteger)toIndex move:(CGFloat)length
{
    CGFloat fromCellHeight = [_rowHeightArr[fromIndex] floatValue];
    CGFloat toCellHeight = [_rowHeightArr[toIndex] floatValue];
    
    CGRect selectViewFrame = _selectView.frame;
    
    switch (_titleWidthStyle) {
        case BKSlideMenuViewTitleWidthStyleDefault:
        {
            CGFloat cell1_cell2_heightGaps = 0;
            if (moveLength>0) {
                cell1_cell2_heightGaps = fromCellHeight - toCellHeight;
                selectViewFrame.origin.y = selectViewFrame.origin.y - moveLength/slideView.frame.size.width * toCellHeight;
            }else if (moveLength<0){
                cell1_cell2_heightGaps = toCellHeight - fromCellHeight;
                selectViewFrame.origin.y = selectViewFrame.origin.y - moveLength/slideView.frame.size.width * fromCellHeight;
            }
            
            selectViewFrame.size.height = selectViewFrame.size.height - moveLength/slideView.frame.size.width *cell1_cell2_heightGaps;
        }
            break;
        case BKSlideMenuViewTitleWidthStyleSame:
        {
            selectViewFrame.origin.y = selectViewFrame.origin.y - moveLength/slideView.frame.size.width * _menuTitleLength;
        }
            break;
        default:
            break;
    }
    
    _selectView.frame = selectViewFrame;
}

/**
 *     SlideView 结束滑动
 **/
-(void)endScrollWith:(BKSlideView*)slideView
{
    if (_selectStyle == BKSlideMenuViewSelectStyleNone) {
        return;
    }
    
    if (isMenuTapFlag) {
        return;
    }
    
    if (isScrollFlag) {
        isScrollFlag = NO;
    }
    
    NSInteger selectIndex = [[NSString stringWithFormat:@"%f",slideView.contentOffset.y/slideView.frame.size.width] integerValue];
    
    CGFloat cellHeight = [_rowHeightArr[selectIndex] floatValue];
    CGFloat cellY = [_rowYArr[selectIndex] floatValue];
    
    CGRect selectViewFrame = _selectView.frame;
    selectViewFrame.size.height = cellHeight;
    selectViewFrame.origin.y = cellY;
    _selectView.frame = selectViewFrame;
    
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectIndex inSection:0];
    UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
    
    UILabel * titleLab = (UILabel*)[cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
    
//    更改选中title 样式
    
    if (_selectStyle & BKSlideMenuViewSelectStyleChangeFont) {
        
        CGFloat fontGap = _selectMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize;
        titleLab.transform = CGAffineTransformMakeScale(fontGap, fontGap);
        
        [_menuTitleZoomArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_menuTitleZoomArr replaceObjectAtIndex:idx withObject:@"1"];
            
            if (idx == selectIndex) {
                [_menuTitleZoomArr replaceObjectAtIndex:selectIndex withObject:[NSString stringWithFormat:@"%f",fontGap]];
            }
        }];
    }
    
    if (_selectStyle & BKSlideMenuViewSelectStyleChangeColor) {
        
        titleLab.textColor = _selectMenuTitleColor;
        
        [_menuTitleColorArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_menuTitleColorArr replaceObjectAtIndex:idx withObject:_normalMenuTitleColor];
            
            if (idx == selectIndex) {
                [_menuTitleColorArr replaceObjectAtIndex:selectIndex withObject:_selectMenuTitleColor];
            }
        }];
    }
    
//    ********************************************
//    更换旧的选中title
    oldSelectLab = titleLab;
    oldTapIndex = selectIndex;
    
//    ********************************************
}

#pragma mark - 滑动动画格式

/**
 *     点击动画选择
 **/
-(void)tapChangeIndex:(NSInteger)index animation:(BKSlideMenuViewChangeStyle)style
{
//    滑动样式
    CGFloat cellY = [_rowYArr[index] floatValue];
    CGFloat cellRow = [_rowHeightArr[index] floatValue];
    switch (style) {
        case 0:
        {
            [self tapCellDefaultAnimationWithCellY:cellY cellRow:cellRow];
        }
            break;
        case 1:
        {
            [self tapCellCenterAnimationWithCellY:cellY cellRow:cellRow];
        }
            break;
        default:
            break;
    }
}

/**
 *     Tap Default
 **/
-(void)tapCellDefaultAnimationWithCellY:(CGFloat)cellY cellRow:(CGFloat)cellRow
{
    CGFloat selectViewPositionGaps = cellRow + cellY - self.contentOffset.y;
    if (selectViewPositionGaps > self.frame.size.width) {
        [self setContentOffset:CGPointMake(0, self.contentOffset.y + (selectViewPositionGaps - self.frame.size.width)) animated:YES];
    }else if (cellY - self.contentOffset.y < 0) {
        [self setContentOffset:CGPointMake(0, cellY) animated:YES];
    }
}

/**
 *     Tap Center
 **/
-(void)tapCellCenterAnimationWithCellY:(CGFloat)cellY cellRow:(CGFloat)cellRow
{
    CGFloat selectViewPositionGaps = cellRow + cellY - self.contentOffset.y;
    CGFloat left_right_Gap = (self.frame.size.width - cellRow)/2.0f;
    if (selectViewPositionGaps > self.frame.size.width - left_right_Gap) {
        CGFloat move = cellY - left_right_Gap;
        if (move > self.contentSize.height - self.frame.size.width) {
            move = self.contentSize.height - self.frame.size.width;
        }
        [self setContentOffset:CGPointMake(0,move) animated:YES];
    }else if (cellY - self.contentOffset.y < left_right_Gap) {
        CGFloat move = cellY - left_right_Gap;
        if (move<0) {
            move = 0;
        }
        [self setContentOffset:CGPointMake(0, move) animated:YES];
    }
}

/**
 *     滑动动画选择
 **/
-(void)moveChangeAnimation:(BKSlideMenuViewChangeStyle)style
{
    switch (style) {
        case 0:
        {
            [self changeSelectViewDefaultAnimation];
        }
            break;
        case 1:
        {
            [self changeSelectViewCenterAnimation];
        }
            break;
        default:
            break;
    }
}

/**
 *     scroll Default
 **/
-(void)changeSelectViewDefaultAnimation
{
    CGFloat selectViewPositionGaps = CGRectGetMaxY(_selectView.frame) - self.contentOffset.y;
    if (selectViewPositionGaps > self.frame.size.width) {
        [self setContentOffset:CGPointMake(0, self.contentOffset.y + (selectViewPositionGaps - self.frame.size.width)) animated:NO];
        if (self.contentOffset.y > self.contentSize.height - self.frame.size.width) {
            [self setContentOffset:CGPointMake(0, self.contentSize.height - self.frame.size.width) animated:NO];
        }
    }else if (_selectView.frame.origin.y - self.contentOffset.y < 0) {
        [self setContentOffset:CGPointMake(0, _selectView.frame.origin.y) animated:NO];
        if (self.contentOffset.y < 0) {
            [self setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }
}

/**
 *     scroll Center
 **/
-(void)changeSelectViewCenterAnimation
{
    CGFloat selectViewPositionGaps = CGRectGetMaxY(_selectView.frame) - self.contentOffset.y;
    CGFloat left_right_Gap = (self.frame.size.width - _selectView.frame.size.height)/2.0f;
    if (selectViewPositionGaps > self.frame.size.width - left_right_Gap) {
        CGFloat move = _selectView.frame.origin.y - left_right_Gap;
        if (move > self.contentSize.height - self.frame.size.width) {
            move = self.contentSize.height - self.frame.size.width;
        }
        [self setContentOffset:CGPointMake(0,move) animated:NO];
    }else if (_selectView.frame.origin.y - self.contentOffset.y < left_right_Gap) {
        CGFloat move = _selectView.frame.origin.y - left_right_Gap;
        if (move<0) {
            move = 0;
        }
        [self setContentOffset:CGPointMake(0, move) animated:NO];
    }
}

#pragma mark - 字体大小

/**
 *     设置 点击 字号大小
 **/
-(void)cellTitleLabFontMagnifyWithNewIndex:(NSInteger)index
{
    oldSelectLab.transform = CGAffineTransformMakeScale(1, 1);
    [_menuTitleZoomArr replaceObjectAtIndex:oldTapIndex withObject:@"1"];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
    
    UILabel * titleLab = (UILabel*)[cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
    
    CGFloat fontMagnifyGap = _selectMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize;
    titleLab.transform = CGAffineTransformMakeScale(fontMagnifyGap, fontMagnifyGap);
    
    [_menuTitleZoomArr replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%f",fontMagnifyGap]];
}

/**
 *     设置 滑动 字号大小
 **/
-(void)scrollSlideViewMagnifyFontWithFromCellIndex:(NSInteger)fromCellIndex toCellIndex:(NSInteger)toCellIndex scrollView:(BKSlideView*)slideView
{
    if (slideView.contentOffset.y <= 0 || slideView.contentOffset.y >= slideView.contentSize.height - slideView.frame.size.width) {
        
        if (fromCellIndex != toCellIndex) {
            NSIndexPath * fromIndexPath = [NSIndexPath indexPathForRow:fromCellIndex inSection:0];
            UITableViewCell * fromCell = [self cellForRowAtIndexPath:fromIndexPath];
            
            UILabel * fromMenuTitleLab = (UILabel*)[fromCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            fromMenuTitleLab.transform = CGAffineTransformMakeScale(1, 1);
            
            [_menuTitleZoomArr replaceObjectAtIndex:fromCellIndex withObject:@"1"];
        }else{
            NSInteger from_index;
            if (slideView.contentOffset.y <= 0) {
                from_index = toCellIndex + 1;
            }else if (slideView.contentOffset.y >= slideView.contentSize.height - slideView.frame.size.width) {
                from_index = toCellIndex - 1;
            }
            
            NSIndexPath * fromIndexPath = [NSIndexPath indexPathForRow:from_index inSection:0];
            UITableViewCell * fromCell = [self cellForRowAtIndexPath:fromIndexPath];
            
            UILabel * fromMenuTitleLab = (UILabel*)[fromCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            fromMenuTitleLab.transform = CGAffineTransformMakeScale(1, 1);
            
            [_menuTitleZoomArr replaceObjectAtIndex:from_index withObject:@"1"];
            
            NSIndexPath * toIndexPath = [NSIndexPath indexPathForRow:toCellIndex inSection:0];
            UITableViewCell * toCell = [self cellForRowAtIndexPath:toIndexPath];
            
            UILabel * toMenuTitleLab = (UILabel*)[toCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            CGFloat fontGap = _selectMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize;
            toMenuTitleLab.transform = CGAffineTransformMakeScale(fontGap, fontGap);
            
            [_menuTitleZoomArr replaceObjectAtIndex:toCellIndex withObject:[NSString stringWithFormat:@"%f",fontGap]];
        }
        
        return;
    }
    
    NSIndexPath * fromIndexPath = [NSIndexPath indexPathForRow:fromCellIndex inSection:0];
    UITableViewCell * fromCell = [self cellForRowAtIndexPath:fromIndexPath];
    
    NSIndexPath * toIndexPath = [NSIndexPath indexPathForRow:toCellIndex inSection:0];
    UITableViewCell * toCell = [self cellForRowAtIndexPath:toIndexPath];
    
    CGFloat fromCellTitleFont = [_menuTitleZoomArr[fromCellIndex] floatValue];
    CGFloat toCellTitleFont = [_menuTitleZoomArr[toCellIndex] floatValue];
    
    CGFloat fontGap = _selectMenuTitleFont.pointSize / _normalMenuTitleFont.pointSize - 1;
    CGFloat fontChange = moveLength/slideView.frame.size.width * fontGap;
    
    CGFloat fromFont = 0;
    CGFloat toFont = 0;
    if (moveLength < 0) {
        fromFont = fromCellTitleFont + fontChange;
        toFont = toCellTitleFont - fontChange;
    }else if (moveLength > 0) {
        fromFont = fromCellTitleFont - fontChange;
        toFont = toCellTitleFont + fontChange;
    }
    
    if (fromCell || toCell) {
        UILabel * fromMenuTitleLab = (UILabel*)[fromCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
        UILabel * toMenuTitleLab = (UILabel*)[toCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
        
        fromMenuTitleLab.transform = CGAffineTransformMakeScale(fromFont,fromFont);
        toMenuTitleLab.transform = CGAffineTransformMakeScale(toFont,toFont);
    }
    
    [_menuTitleZoomArr replaceObjectAtIndex:fromCellIndex withObject:[NSString stringWithFormat:@"%f",fromFont]];
    [_menuTitleZoomArr replaceObjectAtIndex:toCellIndex withObject:[NSString stringWithFormat:@"%f",toFont]];
}

#pragma mark - 字体颜色

/**
 *     设置 点击 字体颜色
 **/
-(void)cellTitleChangeColorWithNewIndex:(NSInteger)index
{
    oldSelectLab.textColor = _normalMenuTitleColor;
    [_menuTitleColorArr replaceObjectAtIndex:oldTapIndex withObject:_normalMenuTitleColor];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
    
    UILabel * titleLab = (UILabel*)[cell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
    
    titleLab.textColor = _selectMenuTitleColor;
    [_menuTitleColorArr replaceObjectAtIndex:index withObject:_selectMenuTitleColor];
}

/**
 *     设置 滑动 字体颜色 透明度
 **/
-(void)scrollSlideViewChangeSelectColorWithFromCellIndex:(NSInteger)fromCellIndex toCellIndex:(NSInteger)toCellIndex scrollView:(BKSlideView*)slideView
{
    if (slideView.contentOffset.y <= 0 || slideView.contentOffset.y >= slideView.contentSize.height - slideView.frame.size.width) {
        
        if (fromCellIndex != toCellIndex) {
            NSIndexPath * fromIndexPath = [NSIndexPath indexPathForRow:fromCellIndex inSection:0];
            UITableViewCell * fromCell = [self cellForRowAtIndexPath:fromIndexPath];
            
            UILabel * fromMenuTitleLab = (UILabel*)[fromCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            fromMenuTitleLab.textColor = _normalMenuTitleColor;
            
            [_menuTitleColorArr replaceObjectAtIndex:fromCellIndex withObject:_normalMenuTitleColor];
        }else{
            NSInteger from_index;
            if (slideView.contentOffset.y <= 0) {
                from_index = toCellIndex + 1;
            }else if (slideView.contentOffset.y >= slideView.contentSize.height - slideView.frame.size.width) {
                from_index = toCellIndex - 1;
            }
            
            NSIndexPath * fromIndexPath = [NSIndexPath indexPathForRow:from_index inSection:0];
            UITableViewCell * fromCell = [self cellForRowAtIndexPath:fromIndexPath];
            
            UILabel * fromMenuTitleLab = (UILabel*)[fromCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            fromMenuTitleLab.textColor = _normalMenuTitleColor;
            
            [_menuTitleColorArr replaceObjectAtIndex:from_index withObject:_normalMenuTitleColor];
            
            NSIndexPath * toIndexPath = [NSIndexPath indexPathForRow:toCellIndex inSection:0];
            UITableViewCell * toCell = [self cellForRowAtIndexPath:toIndexPath];
            
            UILabel * toMenuTitleLab = (UILabel*)[toCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
            toMenuTitleLab.textColor = _selectMenuTitleColor;
            
            [_menuTitleColorArr replaceObjectAtIndex:toCellIndex withObject:_selectMenuTitleColor];
        }
        
        return;
    }
    
    NSIndexPath * fromIndexPath = [NSIndexPath indexPathForRow:fromCellIndex inSection:0];
    UITableViewCell * fromCell = [self cellForRowAtIndexPath:fromIndexPath];
    
    NSIndexPath * toIndexPath = [NSIndexPath indexPathForRow:toCellIndex inSection:0];
    UITableViewCell * toCell = [self cellForRowAtIndexPath:toIndexPath];
    
    UIColor * fromCellTitleColor = _menuTitleColorArr[fromCellIndex];
    UIColor * toCellTitleColor = _menuTitleColorArr[toCellIndex];
    
    CGFloat fromCellTitleAlpha = [[fromCellTitleColor valueForKey:@"alphaComponent"] floatValue];
    CGFloat toCellTitleAlpha = [[toCellTitleColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat fromCellTitleR = [[fromCellTitleColor valueForKey:@"redComponent"] floatValue];
    CGFloat toCellTitleR = [[toCellTitleColor valueForKey:@"redComponent"] floatValue];
    
    CGFloat fromCellTitleG = [[fromCellTitleColor valueForKey:@"greenComponent"] floatValue];
    CGFloat toCellTitleG = [[toCellTitleColor valueForKey:@"greenComponent"] floatValue];
    
    CGFloat fromCellTitleB = [[fromCellTitleColor valueForKey:@"blueComponent"] floatValue];
    CGFloat toCellTitleB = [[toCellTitleColor valueForKey:@"blueComponent"] floatValue];
    
    CGFloat alphaGap = [[_selectMenuTitleColor valueForKey:@"alphaComponent"] floatValue] - [[_normalMenuTitleColor valueForKey:@"alphaComponent"] floatValue];
    CGFloat RGap = [[_selectMenuTitleColor valueForKey:@"redComponent"] floatValue] - [[_normalMenuTitleColor valueForKey:@"redComponent"] floatValue];
    CGFloat GGap = [[_selectMenuTitleColor valueForKey:@"greenComponent"] floatValue] - [[_normalMenuTitleColor valueForKey:@"greenComponent"] floatValue];
    CGFloat BGap = [[_selectMenuTitleColor valueForKey:@"blueComponent"] floatValue] - [[_normalMenuTitleColor valueForKey:@"blueComponent"] floatValue];
    
    CGFloat alphaChange = moveLength/slideView.frame.size.width * alphaGap;
    CGFloat RChange = moveLength/slideView.frame.size.width * RGap;
    CGFloat GChange = moveLength/slideView.frame.size.width * GGap;
    CGFloat BChange = moveLength/slideView.frame.size.width * BGap;
    
    CGFloat fromAlpha = 0;
    CGFloat toAlpha = 0;
    CGFloat fromR = 0;
    CGFloat toR = 0;
    CGFloat fromG = 0;
    CGFloat toG = 0;
    CGFloat fromB = 0;
    CGFloat toB = 0;
    if (moveLength < 0) {
        fromAlpha = fromCellTitleAlpha + alphaChange;
        toAlpha = toCellTitleAlpha - alphaChange;
        fromR = fromCellTitleR + RChange;
        toR = toCellTitleR - RChange;
        fromG = fromCellTitleG + GChange;
        toG = toCellTitleG - GChange;
        fromB = fromCellTitleB + BChange;
        toB = toCellTitleB - BChange;
    }else if (moveLength > 0) {
        fromAlpha = fromCellTitleAlpha - alphaChange;
        toAlpha = toCellTitleAlpha + alphaChange;
        fromR = fromCellTitleR - RChange;
        toR = toCellTitleR + RChange;
        fromG = fromCellTitleG - GChange;
        toG = toCellTitleG + GChange;
        fromB = fromCellTitleB - BChange;
        toB = toCellTitleB + BChange;
    }
    
    UIColor * new_fromChangeColor = [UIColor colorWithRed:fromR green:fromG blue:fromB alpha:fromAlpha];
    UIColor * new_toChangeColor = [UIColor colorWithRed:toR green:toG blue:toB alpha:toAlpha];
    
    if (fromCell || toCell) {
        UILabel * fromMenuTitleLab = (UILabel*)[fromCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
        UILabel * toMenuTitleLab = (UILabel*)[toCell viewWithTag:BKSlideMenuViewCell_tilteLab_tag];
        
        fromMenuTitleLab.textColor = new_fromChangeColor;
        toMenuTitleLab.textColor = new_toChangeColor;
    }
    
    [_menuTitleColorArr replaceObjectAtIndex:fromCellIndex withObject:new_fromChangeColor];
    [_menuTitleColorArr replaceObjectAtIndex:toCellIndex withObject:new_toChangeColor];
}

@end
