//
//  ActivityViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ActivityFilterView;

@interface ActivityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ActivityStreamDelegate, TaloolGiftAcceptedDelegate>
{
    IBOutlet UITableView *tableView;
}
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIRefreshControl *refreshControl;

@property (retain, nonatomic) NSArray *activities;

@property (retain, nonatomic) ActivityFilterView *filterView;

@end