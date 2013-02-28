//
//  ProfileTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "MerchantCell.h"
#import "TaloolUser.h"

@class MerchantController;
@class Merchant;

@interface ProfileTableViewController : BaseTableViewController {
    MerchantController *merchantController;
}

@end