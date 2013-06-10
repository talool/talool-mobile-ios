//
//  ProfileTableViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BaseSearchViewController.h"
#import "TaloolProtocols.h"

@class ttCategory;

@interface MechantTableViewController : UITableViewController<ProximitySliderDelegate, MerchantFilterDelegate, CLLocationManagerDelegate, TaloolLogoutDelegate, TaloolGiftAcceptedDelegate> {
    NSArray *merchants;
}

@property (nonatomic, retain) NSArray *merchants;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSArray *allMerchantsInProximity;
@property (strong,nonatomic) NSMutableArray *filteredMerchants;
//@property IBOutlet UISearchBar *merchantSearchBar;

// is the list being used for "my deals" or "explore"
@property BOOL searchMode;

// lots of non-sense to support switching users and avoiding "null" distances
@property BOOL newCustomerHandled;

@property BOOL newGiftHandled;

// search filters
@property int proximity;
@property (nonatomic, retain) NSPredicate *selectedFilter;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *customerLocation;
@property (strong, nonatomic) CLLocation *lastLocation;
@property int lastProximity;
@property BOOL locationChanged;
@property BOOL proximityChanged;
@property BOOL locationManagerEnabled;

enum {
    LOCATION_UNAVAILABLE = 0,
    LOCATION_CHANGED = 1,
    LOCATION_UNCHANGED = 2
};
typedef int LocationUpdateType;

@end