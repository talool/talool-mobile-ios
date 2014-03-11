//
//  DealOfferTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Braintree/BTPaymentViewController.h>
#import "TaloolProtocols.h"

#define ACTION_VIEW_HEIGHT 40.0f
#define SUMMARY_VIEW_HEIGHT 190.0f

@interface DealOfferTableViewController : UITableViewController<BTPaymentViewControllerDelegate, TaloolDealOfferActionDelegate, NSFetchedResultsControllerDelegate, OperationQueueDelegate, FundraisingCodeDelegate>

@property (strong, nonatomic) ttDealOffer *offer;

@end
