
# BKSliderView 基本用法

TabTab- (void)viewDidLoad {
TabTab    [super viewDidLoad];
TabTab    NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];
TabTab    menuView = [[BKSlideMenuView alloc]initWithFrame:(CGRect) menuTitleArray:titleArray];
TabTab    menuView.customDelegate = self;
TabTab    [self.view addSubview:menuView];
TabTab    theSlideView = [[BKSlideView alloc]initWithFrame:(CGRect) allPageNum:[titleArray count] delegate:self];
TabTab    theSlideView.customDelegate = self;
TabTab    [self.view addSubview:theSlideView];
TabTab}

## SlideViewDelegate
-(void)scrollSlideView:(UICollectionView *)slideView {
    if ([theSlideView.slideView isEqual:slideView]) {
        [menuView scrollWith:theSlideView.slideView];
    }
}

-(void)endScrollSlideView:(UICollectionView *)slideView {
    if ([theSlideView.slideView isEqual:slideView]) {
        [menuView endScrollWith:theSlideView.slideView];
    }
}

-(void)initInView:(UIView *)view atIndex:(NSInteger)index {
    //创建View
}

## SlideMenuViewDelegate

-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index {
    [theSlideView rollSlideViewToIndexView:index];
}