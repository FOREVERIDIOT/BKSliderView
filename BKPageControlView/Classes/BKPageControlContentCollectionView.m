//
//  BKPageControlContentCollectionView.m
//  BKPageControlView
//
//  Created by 毕珂 on 2020/9/28.
//

#import "BKPageControlContentCollectionView.h"
#import "UIView+BKPageControlView.h"

@interface BKPageControlContentCollectionView() <UIGestureRecognizerDelegate>

@end

@implementation BKPageControlContentCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    self.bounces = NO;
    self.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self];
        if ((self.contentOffset.x <= 0 && velocity.x > 0) ||
            (self.contentOffset.x >= (self.contentSize.width - self.width) && velocity.x < 0)) {
            gestureRecognizer.enabled = NO;
            dispatch_after(0.000001, dispatch_get_main_queue(), ^{
                gestureRecognizer.enabled = YES;
            });
            return YES;
        }
    }
    return NO;
}

@end
