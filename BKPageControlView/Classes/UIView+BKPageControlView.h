//
//  UIView+BKPageControlView.h
//  BKPageControlView
//
//  Created by 毕珂 on 2020/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (BKPageControlView)

/// x
@property (nonatomic, assign) CGFloat x;
/// y
@property (nonatomic, assign) CGFloat y;
/// width
@property (nonatomic, assign) CGFloat width;
/// height
@property (nonatomic, assign) CGFloat height;
/// origin
@property (nonatomic, assign) CGPoint origin;
/// size
@property (nonatomic, assign) CGSize size;
/// centerX
@property (nonatomic, assign) CGFloat centerX;
/// centerY
@property (nonatomic, assign) CGFloat centerY;
/// maxX
@property (nonatomic, assign, readonly) CGFloat maxX;
/// maxY
@property (nonatomic, assign, readonly) CGFloat maxY;

@end

NS_ASSUME_NONNULL_END
