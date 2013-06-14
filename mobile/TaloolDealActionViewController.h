//
//  TaloolDealActionViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"
#import <CoreLocation/CoreLocation.h>

@class ttDealAcquire, TaloolUIButton;

@interface TaloolDealActionViewController : UIViewController<CLLocationManagerDelegate,UIAlertViewDelegate> {
    IBOutlet TaloolUIButton *facebookButton;
    IBOutlet TaloolUIButton *emailButton;
    IBOutlet TaloolUIButton *redeemButton;
    IBOutlet TaloolUIButton *cancelButton;
    id <TaloolDealActionDelegate> dealActionDelegate;
}

@property (retain) id dealActionDelegate;
@property (strong, nonatomic) ttDealAcquire *deal;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *merchantLocation;
@property (strong, nonatomic) CLLocation *customerLocation;
@property (nonatomic) CLLocationDistance distance;

- (IBAction)openContactPickerAction:(id)sender;
- (IBAction)openFBPickerAction:(id)sender;
- (IBAction)redeemAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
