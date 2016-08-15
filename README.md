
# BKSliderView 基本用法

- (void)viewDidLoad {

    <br>[super viewDidLoad];

    <br>NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];
    <br>menuView = [[BKSlideMenuView alloc]initWithFrame:(CGRect) menuTitleArray:titleArray];
    <br>menuView.customDelegate = self;
    <br>[self.view addSubview:menuView];
    <br>theSlideView = [[BKSlideView alloc]initWithFrame:(CGRect) allPageNum:[titleArray count] delegate:self];
    <br>theSlideView.customDelegate = self;
    <br>[self.view addSubview:theSlideView];
}

## SlideViewDelegate
-(void)scrollSlideView:(UICollectionView *)slideView {
    <br>if ([theSlideView.slideView isEqual:slideView]) {
    <br>    [menuView scrollWith:theSlideView.slideView];
    <br>}
}

-(void)endScrollSlideView:(UICollectionView *)slideView {
    <br>if ([theSlideView.slideView isEqual:slideView]) {
    <br>    [menuView endScrollWith:theSlideView.slideView];
    <br>}
}

-(void)initInView:(UIView *)view atIndex:(NSInteger)index {
    <br>//创建View
}

## SlideMenuViewDelegate

-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index {
    <br>[theSlideView rollSlideViewToIndexView:index];
}