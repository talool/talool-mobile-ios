//
//  DealOfferTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttMerchant;

@interface DealOfferTableViewController : UITableViewController
{
    NSArray *dealOffers;
    ttMerchant *merchant;
}
@property (nonatomic, retain) NSArray *dealOffers;
@property (nonatomic, retain) ttMerchant *merchant;

@end
