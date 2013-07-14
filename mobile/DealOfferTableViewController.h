//
//  DealOfferTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"
#import "HelpDealOfferLocationViewController.h"

#define HEADER_HEIGHT 70.0f


@class MerchantLogoView, OfferActionView, ttDealOffer, SKProduct;

@interface DealOfferTableViewController : UITableViewController<HelpDealOfferLocationDelegate>

@property (strong, nonatomic) MerchantLogoView *detailView;
@property (strong, nonatomic) OfferActionView *actionView;

@end
