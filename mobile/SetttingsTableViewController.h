//
//  SetttingsTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"

@interface SetttingsTableViewController : UITableViewController {
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
}
- (IBAction)logout:(id)sender;

@property (nonatomic, retain) ttCustomer *customer;
@end
