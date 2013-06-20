//
//  ProfileTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMerchantTableViewController.h"
#import "TaloolProtocols.h"

@class ttCategory;

@interface MerchantTableViewController : BaseMerchantTableViewController<TaloolLogoutDelegate, TaloolGiftAcceptedDelegate>

// lots of non-sense to support switching users and gifts
@property BOOL newCustomerHandled;
@property BOOL newGiftHandled;

@end