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

#define ACTION_VIEW_HEIGHT 237.0f

@interface DealOfferTableViewController : UITableViewController<BTPaymentViewControllerDelegate, TaloolDealOfferActionDelegate, NSFetchedResultsControllerDelegate, OperationQueueDelegate>

@property (strong, nonatomic) ttDealOffer *offer;

@end
