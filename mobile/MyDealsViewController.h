//
//  MyDealsViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class MerchantSearchView;

@interface MyDealsViewController : UITableViewController<OperationQueueDelegate, NSFetchedResultsControllerDelegate, MerchantFilterDelegate>

@property (strong, nonatomic) UIButton *helpButton;
@property (retain, nonatomic) MerchantSearchView *searchView;

@end
