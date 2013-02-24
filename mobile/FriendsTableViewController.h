//
//  FriendsTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseTableViewController.h"
#import "FriendCell.h"

@class CustomerController;
@class Friend;

@interface FriendsTableViewController : BaseTableViewController {
    CustomerController *customerController;
}

@end
