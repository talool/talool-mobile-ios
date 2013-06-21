//
//  SetttingsTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"
#import "TaloolProtocols.h"

@interface SettingsTableViewController : UITableViewController {
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
    id <TaloolLogoutDelegate> logoutDelegate;
}
- (IBAction)logout:(id)sender;
- (void)logoutUser;
- (void) registerLogoutDelegate:(id <TaloolLogoutDelegate>)delegate;

@property (nonatomic, retain) ttCustomer *customer;
@end
