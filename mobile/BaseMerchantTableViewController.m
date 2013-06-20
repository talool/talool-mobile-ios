//
//  BaseMerchantTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseMerchantTableViewController.h"
#import "FavoriteMerchantCell.h"
#import "MerchantCell.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "TaloolColor.h"

@interface BaseMerchantTableViewController ()

@end

@implementation BaseMerchantTableViewController

@synthesize merchants, sortDescriptors, proximity, selectedFilter, locationManagerEnabled;
@synthesize filteredMerchants, allMerchantsInProximity, locationChanged, proximityChanged, lastProximity;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // TODO what to show if the user hasn't enabled location services?
    if (locationManagerEnabled)
    {
        [self filterMerchants];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshMerchants) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _customerLocation = nil;
    _lastLocation = nil;
    locationChanged = YES;
    proximityChanged = YES;
    
    // is the location service enabled?
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        // It would be interesting to track this. (TODO)
        // the user will be prompted to turn them on when the location
        // manager starts up.
        NSLog(@"The user has disabled location services");
    }
    
    // is the location service authorized?
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        /*
         * TODO
         - track this
         - message user about why it's needed?
         - flag the user obj, so we can avoid errors?
         */
        NSLog(@"The user has denied the use of their location");
    }
    locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filteredMerchants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the data for the cell.
    ttMerchant *merchant = [filteredMerchants objectAtIndex:indexPath.row];
    //[cell setMerchant:merchant];
    ttCategory *cat = (ttCategory *)merchant.category;
    ttMerchantLocation *loc = merchant.location;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"###0.##"];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *miles = [formatter stringFromNumber:[loc getDistanceInMiles]];
    CategoryHelper *helper = [[CategoryHelper alloc] init];
    [cell setIcon:[helper getIcon:[cat.categoryId intValue]]];
    [cell setName:merchant.name];
    if (miles == nil)
    {
        [cell setDistance:@""];
    }
    else
    {
        [cell setDistance: [NSString stringWithFormat:@"%@ miles",miles] ];
    }
    [cell setAddress:[merchant getLocationLabel]];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setRowHeight:60.0];
}

#pragma mark -
#pragma mark - Filters
- (void) filterMerchants
{
    [self updateMerchants];
    
    // Remove all objects from the filtered search array
    [filteredMerchants removeAllObjects];
    
    NSArray *tempArray;
    
    // optional filter based on category or favorites
    if (selectedFilter == nil)
    {
        // show all merchants
        tempArray = [NSMutableArray arrayWithArray:merchants];
    }
    else
    {
        // filter merchants
        tempArray = [NSMutableArray arrayWithArray:[merchants filteredArrayUsingPredicate:selectedFilter]];
    }
    
    
    // filter the array based on proximity
    int prox = proximity;
    if (proximity == 0 || proximity == MAX_PROXIMITY)
    {
        prox = INFINITE_PROXIMITY;
    }
    int proximityInMeters = METERS_PER_MILE * prox;
    NSPredicate *proximityPredicate = [NSPredicate predicateWithFormat:@"ANY locations.distanceInMeters < %d",proximityInMeters];
    tempArray = [tempArray filteredArrayUsingPredicate:proximityPredicate];
    
    filteredMerchants = [NSMutableArray arrayWithArray:tempArray];
    
    [self.tableView reloadData];
}

/*
 * This hits the service for a proximity search if the location changed.
 * It also sorts the main list of merchants, but doesn't filter the set.
 */
-(void) updateMerchants
{
    int prox = proximity;
    if (proximity == 0 || proximity == MAX_PROXIMITY)
    {
        prox = INFINITE_PROXIMITY;
    }
    
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    NSError *error;
    switch ([self getLocationUpdateType]) {
        case LOCATION_CHANGED:
            allMerchantsInProximity = [user getMerchantsByProximity:prox
                                                          longitude:_customerLocation.coordinate.longitude
                                                           latitude:_customerLocation.coordinate.latitude
                                                            context:[CustomerHelper getContext]
                                                              error:&error];
            _lastLocation = _customerLocation;
            lastProximity = proximity;
            [self merchantsUpdatedWithNewLocation];
            
            break;
        case LOCATION_UNAVAILABLE:
            // TODO if there the location services can't get the merchants, how do we fail?
            //  * just query all merchants in the context?
            //  * return all merchants?  eventually, this isn't helpful.
            //  * blank the page and force the user to enable location services
            allMerchantsInProximity = [user getMyMerchants];
            NSLog(@"WHOA! Location unavailavle!!!");
            break;
        default:
            //NSLog(@"Location unchanged");
            break;
    }
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObject:sortByName];
    
    // the set of merchants changes base on the search mode
    merchants = [[[NSArray alloc] initWithArray:[self getAllMerchants]] sortedArrayUsingDescriptors:sortDescriptors];
    
    filteredMerchants = [NSMutableArray arrayWithCapacity:[merchants count]];
    filteredMerchants = [NSMutableArray arrayWithArray:merchants];
}

-(LocationUpdateType) getLocationUpdateType
{
    int type;
    if (_customerLocation == nil)
    {
        type = LOCATION_UNAVAILABLE;
    }
    else if ([self hasLocationChanged])
    {
        type = LOCATION_CHANGED;
    }
    else
    {
        type = LOCATION_UNCHANGED;
    }
    return type;
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshMerchants
{
    // Override in subclass to hit the service
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self filterMerchants];
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - Helpers & Stuff to Override

- (BOOL) hasLocationChanged
{
    // Do we need to force a change when proximity slider changes?
    //  * NO, the range query grabs everything within 9999 miles,
    //    so the filter predicate should be all we need
    return locationChanged;
}
- (void) merchantsUpdatedWithNewLocation
{
    locationChanged = NO;
    proximityChanged = NO;
}
- (NSArray *) getAllMerchants
{
    return allMerchantsInProximity;
}

#pragma mark -
#pragma mark - ProximitySliderDelegate methods

- (void)proximityChanged:(float) valueInMiles sender:(id)sender
{
    proximity = [[[NSNumber alloc] initWithFloat:valueInMiles] intValue];
    proximityChanged = YES;
    [self filterMerchants];
}

#pragma mark -
#pragma mark - MerchantFilterDelegate methods

- (void)filterChanged:(NSPredicate *)filter sender:(id)sender;
{
    selectedFilter = filter;
    [self filterMerchants];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    _customerLocation = newLocation;
    CLLocationDistance distance = [_customerLocation distanceFromLocation:_lastLocation];
    float distanceInMiles = distance/METERS_PER_MILE;
    float minAsFloat = [[NSNumber numberWithInt:METERS_PER_MILE] floatValue];
    if (distanceInMiles > minAsFloat)
    {
        // need to refresh merchants based on new prox
        locationChanged = YES;
    }
    else
    {
        locationChanged = NO;
    }
    
    if (locationManagerEnabled == NO)
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            // we were just authorized, so update the list
            locationManagerEnabled = YES;
            [self filterMerchants];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:@"close"
                                              otherButtonTitles:nil];
	[errorView show];
}


@end
