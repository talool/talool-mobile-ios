//
//  ActivityViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
}
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIRefreshControl *refreshControl;

@end
