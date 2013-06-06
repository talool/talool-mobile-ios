//
//  DealRedemptionViewController.h
//  Talool
//
//  Created by Douglas McCuen on 4/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class ttDealAcquire;

@interface DealRedemptionViewController : UIViewController <UIPageViewControllerDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>

- (IBAction)shareAction:(id)sender;
- (void)redeemAction;

@property (retain, nonatomic) UIBarButtonItem *shareButton;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) ttDealAcquire *deal;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *merchantLocation;
@property (strong, nonatomic) CLLocation *customerLocation;
@property (nonatomic) CLLocationDistance distance;

@end
