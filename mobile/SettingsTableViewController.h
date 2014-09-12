//
//  SetttingsTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Talool-API/ttCustomer.h"
#import "FacebookSDK/FacebookSDK.h"
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface SettingsTableViewController : UITableViewController<FBLoginViewDelegate, OperationQueueDelegate>
{
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *versionLabel;
    IBOutlet TaloolUIButton *logoutButton;
    IBOutlet UITableViewCell *logoutCell;
}
- (IBAction)logout:(id)sender;

@property (nonatomic, retain) ttCustomer *customer;

@end