//
//  CouponeScrollView.h
//  mobile
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttCoupon;

@interface CouponScrollView : UIScrollView
{
    ttCoupon *coupon;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic) NSUInteger index;
@property (nonatomic, retain) ttCoupon *coupon;


@end
