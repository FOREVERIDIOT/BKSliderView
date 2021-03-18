#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BKPageControl.h"
#import "BKPageControlCollectionView.h"
#import "BKPageControlMenu.h"
#import "BKPageControlMenuModel.h"
#import "BKPageControlMenuPropertyModel.h"
#import "BKPageControlScrollView.h"
#import "BKPageControlScrollViewProtocol.h"
#import "BKPageControlSelectLine.h"
#import "BKPageControlView.h"
#import "UIView+BKPageControlView.h"
#import "UIViewController+BKPageControlView.h"

FOUNDATION_EXPORT double BKPageControlViewVersionNumber;
FOUNDATION_EXPORT const unsigned char BKPageControlViewVersionString[];

