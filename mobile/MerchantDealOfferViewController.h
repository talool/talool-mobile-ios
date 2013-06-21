//
//  MerchantDealOfferViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseMerchantDetailViewController.h"

@interface MerchantDealOfferViewController : BaseMerchantDetailViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
    NSArray *dealOffers;
}
@property (nonatomic, retain) NSArray *dealOffers;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIRefreshControl *refreshControl;


@end
