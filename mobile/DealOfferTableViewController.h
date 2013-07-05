//
//  DealOfferTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

#define HEADER_HEIGHT 70.0f


@class OfferDetailView, OfferActionView, ttDealOffer;

@interface DealOfferTableViewController : UITableViewController<DealOfferPurchaseDelegate>

@property (strong, nonatomic) OfferDetailView *detailView;
@property (strong, nonatomic) OfferActionView *actionView;
@property (retain, nonatomic) ttDealOffer *offer;
@property (retain, nonatomic) NSArray *deals;

@end