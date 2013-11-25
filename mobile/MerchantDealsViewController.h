//
//  MerchantDealsViewController.h
//  Talool
//
//  Created by Douglas McCuen on 11/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealOffer, ttMerchant;

#define OFFER_MERCHANT_VIEW_HEIGHT 182.0f

@interface MerchantDealsViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ttDealOffer *offer;
@property (strong, nonatomic) ttMerchant *merchant;

@end
