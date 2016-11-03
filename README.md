
# BKSliderView 基本用法

## 创建
    @property (nonatomic,strong) BKSlideView * slideView;

    - (void)viewDidLoad {
        [super viewDidLoad];

        NSMutableArray * vcArray = [NSMutableArray array];
        for (int i = 0 ; i<10; i++) {
            UIViewController * vc = [[UIViewController alloc]init];
            vc.title = [NSString stringWithFormat:@"第%d个",i];
            vc.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0f green:arc4random()%255/255.0f blue:arc4random()%255/255.0f alpha:1];
            [vcArray addObject:vc];
        }

        _slideView = [[BKSlideView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) vcArray:vcArray];
        _slideView.slideMenuViewChangeStyle = SlideMenuViewChangeStyleCenter;
        [self.view addSubview:_slideView];
    }

