//
//  SetttingsTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"

@interface SettingsTableViewController : UITableViewController {
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIActivityIndicatorView *spinner;
}
- (IBAction)logout:(id)sender;
- (void)logoutUser;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) ttCustomer *customer;

@end
