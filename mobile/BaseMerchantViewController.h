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

@class MerchantFilterControl;

@interface BaseMerchantViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {
    NSArray *merchants;
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UISlider *distanceSlider;
}

- (IBAction)proximitySliderValueChanged:(id)sender;

@property (strong, nonatomic) MerchantFilterControl *filterControl;
@property Boolean isExplore;

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, retain) NSArray *merchants;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSArray *allMerchantsInProximity;
@property (strong,nonatomic) NSMutableArray *filteredMerchants;

// search filters
@property int proximity;
@property (nonatomic, retain) NSPredicate *selectedFilter;

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *customerLocation;
@property (strong, nonatomic) CLLocation *lastLocation;
@property int lastProximity;
@property BOOL locationChanged;
@property BOOL proximityChanged;
@property BOOL locationManagerEnabled;

- (void) refreshMerchants;
- (BOOL) hasLocationChanged;
- (void) merchantsUpdatedWithNewLocation;
- (NSArray *) getAllMerchants;

enum {
    LOCATION_UNAVAILABLE = 0,
    LOCATION_CHANGED = 1,
    LOCATION_UNCHANGED = 2
};
typedef int LocationUpdateType;

@end
