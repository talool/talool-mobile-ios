//
//  DealRedemptionViewController.h
//  Talool
//
//  Created by Douglas McCuen on 4/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttDealAcquire;

@interface DealRedemptionViewController : UIViewController <UIPageViewControllerDelegate,FBFriendPickerDelegate,UIAlertViewDelegate>

- (IBAction)shareAction:(id)sender;
- (void)redeemAction;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) ttDealAcquire *deal;

@end
