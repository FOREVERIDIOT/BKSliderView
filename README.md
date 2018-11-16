
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
    UIViewController * vc = [[UIViewController alloc] init];
    //title必须传 且 不能重复
    vc.title = [NSString stringWithFormat:@"第%d个",i];
    [viewControllers addObject:vc];
}
2.创建BKSliderView并添加到view上 遵循代理 赋值viewControllers
BKSlideView * slideView = [[BKSlideView alloc] initWithFrame:(CGRect) delegate:(id<BKSlideViewDelegate>) viewControllers:(NSArray *)];
[view addSubview:slideView];
3.遵循必要代理
-(void)slideView:(BKSlideView*)slideView createViewControllerWithIndex:(NSUInteger)index
{
    //每个viewController只会执行一次
    //在这里可以给对应viewController传输消息,使之创建UI
}
```

## 可选代理

```objc
/**
 准备离开index

 @param leaveIndex 离开的index
 */
-(void)slideView:(BKSlideView*)slideView leaveIndex:(NSUInteger)leaveIndex;

/**
 切换index

 @param slideView BKSlideView
 @param switchIndex 切换的index
 @param leaveIndex 离开的index
 */
-(void)slideView:(BKSlideView*)slideView switchIndex:(NSUInteger)switchIndex leaveIndex:(NSUInteger)leaveIndex;

/**
 修改详情内容视图的frame

 @param slideView BKSlideView
 */
-(void)slideViewDidChangeFrame:(BKSlideView*)slideView;

#pragma mark - 主视图滑动代理

/**
 滑动主视图
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView didScrollBgScrollView:(UIScrollView*)bgScrollView;

/**
 开始滑动主视图
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView willBeginDraggingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图惯性结束
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView didEndDeceleratingBgScrollView:(UIScrollView*)bgScrollView;

/**
 主视图停止拖拽
 
 @param slideView BKSlideView
 @param bgScrollView 主视图
 */
-(void)slideView:(BKSlideView*)slideView didEndDraggingBgScrollView:(UIScrollView*)bgScrollView willDecelerate:(BOOL)decelerate;
```

## 版本
```
1.0 第一版完成
1.1 第一版太乱，更新成第二版
1.1 添加menu排版 等间距|等宽
```
