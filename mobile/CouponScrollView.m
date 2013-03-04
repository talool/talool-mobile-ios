//
//  CouponeScrollView.m
//  mobile
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CouponScrollView.h"
#import "ttCoupon.h"

@interface CouponScrollView () <UIScrollViewDelegate>

@end


@implementation CouponScrollView

@synthesize coupon;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    [self displayCoupon];
}

- (void) displayCoupon
{
    NSLog(@"display coupon");// TODO
    nameLabel.text = @"foo";//coupon.name;
    self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:117.0/255.0 alpha:1.0];
}

@end



