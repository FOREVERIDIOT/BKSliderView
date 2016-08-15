
# BKSliderView 基本用法
`- (void)viewDidLoad {

    [super viewDidLoad];

    NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];

    menuView = [[BKSlideMenuView alloc]initWithFrame:(CGRect) menuTitleArray:titleArray];

    menuView.customDelegate = self;

    [self.view addSubview:menuView];

    theSlideView = [[BKSlideView alloc]initWithFrame:(CGRect) allPageNum:[titleArray count] delegate:self];

    theSlideView.customDelegate = self;

    [self.view addSubview:theSlideView];
}`

## SlideViewDelegate
`-(void)scrollSlideView:(UICollectionView *)slideView {
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
}`

## SlideMenuViewDelegate
`-(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index {
    [theSlideView rollSlideViewToIndexView:index];
}`