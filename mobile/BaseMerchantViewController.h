//
//  BaseMerchantTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TaloolProtocols.h"

@class MerchantSearchView;

@interface BaseMerchantViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MerchantSearchDelegate> {
    NSArray *merchants;
    IBOutlet UITableView *tableView;
}

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, retain) NSArray *merchants;
@property (retain, nonatomic) MerchantSearchView *searchView;


@end
