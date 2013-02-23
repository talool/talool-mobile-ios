//
//  ExploreTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "MerchantCell.h"

@class MerchantController;
@class Merchant;

@interface ExploreTableViewController : BaseTableViewController {
    MerchantController *merchantController;
}

- (void)showMerchant:(Merchant *)merchant animated:(BOOL)animated;

@end
