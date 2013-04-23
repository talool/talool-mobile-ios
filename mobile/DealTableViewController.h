//
//  DealTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardCell.h"

@class ttMerchant;

@interface DealTableViewController : UITableViewController
{
    NSArray *deals;
    ttMerchant *merchant;
}
@property (nonatomic, retain) NSArray *deals;
@property (nonatomic, retain) ttMerchant *merchant;
@end
