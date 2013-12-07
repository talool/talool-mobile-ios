//
//  DealTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FacebookSDK/FacebookSDK.h"

#define HEADER_HEIGHT 145.0f

@class ttDealAcquire, ttDealOffer, DealRedemptionView, DealLayoutState, DealActionBar3View;

@interface DealTableViewController : UITableViewController<TaloolDealActionDelegate, UIAlertViewDelegate, FBFriendPickerDelegate, ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate, OperationQueueDelegate, PersonViewDelegate>

@property (strong, nonatomic) ttDealAcquire *deal;
@property (strong, nonatomic) ttDealOffer *offer;

@property (strong, nonatomic) DealActionBar3View *actionBar3View;
@property (nonatomic) DealLayoutState *dealLayout;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) FBFrictionlessRecipientCache *friendCache;

@end
