//
//  SetttingsTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"
#import "FacebookSDK/FacebookSDK.h"

#define GA_TRACKING_ID  @"UA-42344079-1"

@class TaloolUIButton;

@interface SettingsTableViewController : UITableViewController<FBLoginViewDelegate>
{
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
    IBOutlet TaloolUIButton *logoutButton;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UITableViewCell *logoutCell;
}
- (IBAction)logout:(id)sender;
- (void)logoutUser;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) ttCustomer *customer;

@end