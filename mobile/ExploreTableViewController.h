//
//  ExploreTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationCell.h"

@class MerchantController;
@class Merchant;

@interface ExploreTableViewController : UITableViewController {
    MerchantController *merchantController;
    ApplicationCell *tmpCell;
	UINib *cellNib;
}

@property (nonatomic, retain) IBOutlet ApplicationCell *tmpCell;

@property (nonatomic, retain) UINib *cellNib;

- (void)showMerchant:(Merchant *)merchant animated:(BOOL)animated;

@end
