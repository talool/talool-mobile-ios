//
//  DataViewController.h
//  PageTurner
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttCoupon;

@interface DataViewController : UIViewController<FBFriendPickerDelegate,UIAlertViewDelegate> {
    
}

- (IBAction)shareAction:(id)sender;
- (IBAction)redeemAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) ttCoupon *coupon;

@end
