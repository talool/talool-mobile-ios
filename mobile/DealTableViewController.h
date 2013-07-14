//
//  DealTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttDealAcquire, ttDealOffer, DealRedemptionView, DealLayoutState;

@interface DealTableViewController : UITableViewController<TaloolDealActionDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, FBFriendPickerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) ttDealAcquire *deal;
@property (strong, nonatomic) ttDealOffer *offer;
@property (strong, nonatomic) DealRedemptionView *redemptionView;
@property (nonatomic) DealLayoutState *dealLayout;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *merchantLocation;
@property (strong, nonatomic) CLLocation *customerLocation;
@property (nonatomic) CLLocationDistance distance;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) FBFrictionlessRecipientCache *friendCache;

@end
