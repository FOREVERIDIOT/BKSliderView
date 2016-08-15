
# BKSliderView 基本用法

## 创建
    @property (nonatomic,strong) BKSlideView * theSlideView;
    @property (nonatomic,strong) BKSlideMenuView * menuView;


    - (void)viewDidLoad {
        [super viewDidLoad];

        NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];

        _menuView = [[BKSlideMenuView alloc]initWithFrame:(CGRect) menuTitleArray:titleArray];
        _menuView.customDelegate = self;
        [self.view addSubview:_menuView];

        _theSlideView = [[BKSlideView alloc]initWithFrame:(CGRect) allPageNum:[titleArray count] delegate:self];
        _theSlideView.customDelegate = self;
        [self.view addSubview:_theSlideView];
    }

## SlideViewDelegate

    -(void)scrollSlideView:(UICollectionView *)slideView {
        if ([_theSlideView.slideView isEqual:slideView]) {
            [_menuView scrollWith:theSlideView.slideView];
        }
    }

    -(void)endScrollSlideView:(UICollectionView *)slideView {
        if ([_theSlideView.slideView isEqual:slideView]) {
            [_menuView endScrollWith:theSlideView.slideView];
        }
    }

    -(void)initInView:(UIView *)view atIndex:(NSInteger)index {
        //创建View
    }

## SlideMenuViewDelegate

    -(void)selectMenuSlide:(BKSlideMenuView *)slideMenuView relativelyViewWithViewIndex:(NSInteger)index {
        [_theSlideView rollSlideViewToIndexView:index];
    }