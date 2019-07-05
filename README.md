
# BKSliderView 

## 介绍
```
很懒 就不介绍了 注释挺全 自己进项目里看吧
```

## 例图
![image](https://github.com/FOREVERIDIOT/BKSliderView/blob/master/Images/r.gif)

## 创建

```objc
1.创建viewController数组
NSMutableArray * viewControllers = [NSMutableArray array];
for (int i = 0; i<10; i++) {
    BKPageControlViewController * vc = [[BKPageControlViewController alloc] init];
    //title必须传
    vc.title = [NSString stringWithFormat:@"第%d个",i];
    [viewControllers addObject:vc];
}
2.创建BKSliderView并添加到view上
BKSliderView * sliderView = [[BKPageControlView alloc] initWithFrame:(CGRect) delegate:(id<BKPageControlViewDelegate>) childControllers:(NSArray<BKPageControlViewController *> *) superVC:(UIViewController *)];
[view addSubview:sliderView];
```
