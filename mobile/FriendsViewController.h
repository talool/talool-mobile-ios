//
//  FriendsViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "talool-service.h"


@interface FriendsViewController : UIViewController {
    Customer *customer;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic, retain) Customer *customer;

@end
