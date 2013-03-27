//
//  DealTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardCell.h"
#import "talool-api-ios/ttCoupon.h"
#import "talool-api-ios/ttMerchant.h"

@interface DealTableViewController : UITableViewController
{
    NSMutableArray *deals;
    ttMerchant *merchant;
}
@property (nonatomic, retain) NSMutableArray *deals;
@property (nonatomic, retain) ttMerchant *merchant;
@end
