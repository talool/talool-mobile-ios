//
//  ProfileTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MerchantCell.h"
#import "talool-api-ios/ttMerchant.h"

@interface MechantTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate> {
    NSArray *merchants;
}
@property (nonatomic, retain) NSArray *merchants;
@property (nonatomic, retain) NSArray *sortDescriptors;

@property (strong,nonatomic) NSMutableArray *filteredMerchants;
@property IBOutlet UISearchBar *merchantSearchBar;

@property BOOL searchMode;

@end