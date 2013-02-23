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
    FriendCell *tmpCell;
    UINib *cellNib;
}

@property (nonatomic, retain) IBOutlet FriendCell *tmpCell;

@property (nonatomic, retain) UINib *cellNib;

- (void)showFriend:(Customer *)friend animated:(BOOL)animated;

@end
