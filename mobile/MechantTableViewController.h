//
//  ProfileTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"

@interface MechantTableViewController : UITableViewController<ProximitySliderDelegate> {
    NSArray *merchants;
}
@property (nonatomic, retain) NSArray *merchants;
@property (nonatomic, retain) NSArray *sortDescriptors;

@property (strong,nonatomic) NSMutableArray *filteredMerchants;
//@property IBOutlet UISearchBar *merchantSearchBar;

// is the list being used for "my deals" or "explore"
@property BOOL searchMode;

// searchh filters
@property (nonatomic) int filterIndex;
@property int proximity;

- (void) setFilterIndex:(int)filterIndex;

@end