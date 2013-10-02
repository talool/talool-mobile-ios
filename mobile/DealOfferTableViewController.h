//
//  DealOfferTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpDealOfferLocationViewController.h"
#import <Braintree/BTPaymentViewController.h>
#import "TaloolProtocols.h"

#define ACTION_VIEW_HEIGHT 95.0f
#define ACCESS_CODE_HEIGHT 180.0f
#define MAP_CELL_HEIGHT 120.0f
#define DEAL_CELL_HEIGHT 60.0f

@interface DealOfferTableViewController : UITableViewController<HelpDealOfferLocationDelegate, BTPaymentViewControllerDelegate, TaloolDealOfferActionDelegate>

@property (strong, nonatomic) UIButton *helpButton;

@end
