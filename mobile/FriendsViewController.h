//
//  FriendsViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"


@interface FriendsViewController : UIViewController {
    ttCustomer *customer;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic, retain) ttCustomer *customer;

@end
