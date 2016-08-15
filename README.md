
# BKSliderView 基本用法

- (void)viewDidLoad {

    [super viewDidLoad];

    NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];\<br>
    menuView = [[BKSlideMenuView alloc]initWithFrame:(CGRect) menuTitleArray:titleArray];\<br>
    menuView.customDelegate = self;\<br>
    [self.view addSubview:menuView];\<br>
    theSlideView = [[BKSlideView alloc]initWithFrame:(CGRect) allPageNum:[titleArray count] delegate:self];\<br>
    theSlideView.customDelegate = self;\<br>
    [self.view addSubview:theSlideView];\<br>
}

## SlideViewDelegate
-(void)scrollSlideView:(UICollectionView *)slideView {
    if ([theSlideView.slideView isEqual:slideView]) {\<br>
        [menuView scrollWith:theSlideView.slideView];\<br>
    }\<br>
}

-(void)endScrollSlideView:(UICollectionView *)slideView {
    if ([theSlideView.slideView isEqual:slideView]) {\<br>
        [menuView endScrollWith:theSlideView.slideView];\<br>
    }\<br>
}

-(void)initInView:(UIView *)view atIndex:(NSInteger)index {
    //创建View\<br>
}

## SlideMenuViewDelegate

-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index {
    [theSlideView rollSlideViewToIndexView:index];\<br>
}