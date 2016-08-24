
# BKSliderView 基本用法

## 创建
    @property (nonatomic,strong) BKSlideView * slideView;

    - (void)viewDidLoad {
        [super viewDidLoad];

        NSArray * titleArray = @[@"第一个",@"第二个",@"第三个",@"第四个",@"这是一个很长的title",@"~~~~~~",@"倒数第二个",@"倒一"];

        slideView = [[BKSlideView alloc]initWithFrame:(CGRect) menuTitleArray:titleArray delegate:self];
        [self.view addSubview:slideView];
    }

## SlideViewDelegate

    -(void)initInView:(UIView *)view atIndex:(NSInteger)index {
        //创建View
    }
