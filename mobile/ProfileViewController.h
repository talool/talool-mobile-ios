//
//  FirstViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"


@interface ProfileViewController : UIViewController {
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
}

- (void)settings:(id)sender;

@property (nonatomic, retain) ttCustomer *customer;

@end
