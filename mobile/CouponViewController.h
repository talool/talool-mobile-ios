//
//  CouponViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponViewController : UIViewController <UIPageViewControllerDelegate>

+ (CouponViewController *)couponViewControllerForPageIndex:(NSUInteger)pageIndex;

- (NSInteger)pageIndex;
+ (NSArray *)getData;

@end
