
# BKSliderView 

## 介绍
```
很懒 就不介绍了 注释挺全 自己进项目里看吧
```

## 例图
![image](https://github.com/FOREVERIDIOT/BKSliderView/blob/master/Images/r.gif)
![image](https://github.com/FOREVERIDIOT/BKSliderView/blob/master/Images/r1.gif)

## 创建方法

```objc
1.创建viewController数组
NSMutableArray * viewControllers = [NSMutableArray array];
for (int i = 0; i<10; i++) {
    //控制器必须遵循代理BKPageControlViewController
    UIViewController * vc = [[UIViewController alloc] init];
    //title必须传
    vc.title = [NSString stringWithFormat:@"第%d个",i];
    [viewControllers addObject:vc];
}
2.创建BKSliderView并添加到view上
BKSliderView * sliderView = [[BKPageControlView alloc] initWithFrame:(CGRect) delegate:(nullable id<BKPageControlViewDelegate>) childControllers:(nullable NSArray<UIViewController<BKPageControlViewController> *> *) superVC:(nonnull UIViewController *)];
[view addSubview:sliderView];
```
