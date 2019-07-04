
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
    //title必须传 且 不能重复
    vc.title = [NSString stringWithFormat:@"第%d个",i];
    [viewControllers addObject:vc];
}
2.创建BKSliderView并添加到view上 遵循代理 赋值viewControllers
BKSliderView * sliderView = [[BKPageControlView alloc] initWithFrame:(CGRect) delegate:(id<BKPageControlViewDelegate>) childControllers:(NSArray<BKPageControlViewController *> *) superVC:(UIViewController *)];
[view addSubview:sliderView];
```

## 可选代理

```objc

/**
 准备离开index

 @param leaveIndex 离开的index
 */
-(void)sliderView:(BKSliderView*)sliderView willLeaveIndex:(NSUInteger)leaveIndex;

/**
 切换index中

 @param sliderView BKSliderView
 @param switchingIndex 切换中的index
 @param leavingIndex 离开中的index
 @param percentage 百分比
 */
-(void)sliderView:(BKSliderView *)sliderView switchingIndex:(NSUInteger)switchingIndex leavingIndex:(NSUInteger)leavingIndex percentage:(CGFloat)percentage;

/**
 切换index

 @param sliderView BKSliderView
 @param switchIndex 切换的index
 @param leaveIndex 离开的index
 */
-(void)sliderView:(BKSliderView*)sliderView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex;

#pragma mark - 主视图滑动代理

/**
 滑动主视图
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView didScrollBgScrollView:(UIScrollView*)bgScrollView;

/**
 开始滑动主视图
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView willBeginDraggingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图惯性结束
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView didEndDeceleratingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图停止拖拽
 
 @param sliderView BKSliderView
 @param bgScrollView 主视图
 */
-(void)sliderView:(BKSliderView*)sliderView didEndDraggingBgScrollView:(UIScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;

#pragma mark - 导航

/**
 导航视图刷新UI代理

 @param sliderView BKSliderView
 @param menuView 导航视图
 */
-(void)sliderView:(BKSliderView *)sliderView refreshMenuUI:(BKSliderMenuView*)menuView;
```
