//
//  ProfileTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MechantTableViewController.h"
#import "FavoriteMerchantCell.h"
#import "MerchantCell.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttCategory.h"
#import "CustomerHelper.h"
#import "AppDelegate.h"
#import "TaloolColor.h"

@interface MechantTableViewController ()

@end

#define METERS_PER_MILE 1609.344
#define MAX_PROXIMITY 200
#define INFINITE_PROXIMITY 9999
#define MIN_PROXIMITY_CHANGE_IN_MILES .05

@implementation MechantTableViewController
@synthesize merchants, sortDescriptors, searchMode, proximity, selectedFilter;
@synthesize filteredMerchants, allMerchantsInProximity, locationChanged, proximityChanged, lastProximity;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self filterMerchants];
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
    [cell setMerchant:merchant];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setRowHeight:60.0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMerchant"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [filteredMerchants objectAtIndex:[indexPath row]];
        
        [[segue destinationViewController] setMerchant:merchant];
        
    }
}

/*
 *  Only called when the user "pulls to refresh" the list.
 *  This is a heavy call.
 */
- (void) refreshMerchants
{
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    [user refreshMerchants:[CustomerHelper getContext]];
    [user refreshFavoriteMerchants:[CustomerHelper getContext]];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self filterMerchants];
    [self.refreshControl endRefreshing];
}

- (void)proximityChanged:(float) valueInMiles sender:(id)sender
{
    proximity = [[[NSNumber alloc] initWithFloat:valueInMiles] intValue];
    proximityChanged = YES;
    [self filterMerchants];
}
- (void)filterChanged:(NSPredicate *)filter sender:(id)sender;
{
    selectedFilter = filter;
    [self filterMerchants];
}

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
    if (proximity == 0)
    {
        proximity = MAX_PROXIMITY;
    }
    int proximityInMeters = METERS_PER_MILE * proximity;
    NSPredicate *proximityPredicate = [NSPredicate predicateWithFormat:@"ANY locations.distanceInMeters < %d",proximityInMeters];
    tempArray = [tempArray filteredArrayUsingPredicate:proximityPredicate];
    
    filteredMerchants = [NSMutableArray arrayWithArray:tempArray];
    
    [self.tableView reloadData];
}

/*
 * This hits the service for a proximity search.
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
    NSError *error = [[NSError alloc] init];
    switch ([self getLocationUpdateType]) {
        case LOCATION_CHANGED:
            allMerchantsInProximity = [user getMerchantsByProximity:prox
                                                          longitude:_customerLocation.coordinate.longitude
                                                           latitude:_customerLocation.coordinate.latitude
                                                            context:[CustomerHelper getContext]
                                                              error:&error];
            _lastLocation = _customerLocation;
            lastProximity = proximity;
            locationChanged = NO;
            proximityChanged = NO;
            break;
        case LOCATION_UNAVAILABLE:
            // TODO if there the location services can't get the merchants, how do we fail?
            //  * just query all merchants in the context?
            //  * return all merchants?  eventually, this isn't helpful.
            //  * blank the page and force the user to enable location services
            allMerchantsInProximity = [user getMyMerchants];
            break;
        default:
            break;
    }
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObject:sortByName];
    
    // the set of merchants changes base on the search mode
    if (searchMode)
    {
        merchants = [[[NSArray alloc] initWithArray:allMerchantsInProximity] sortedArrayUsingDescriptors:sortDescriptors];
    }
    else{
        // getMerchantsByProximity stored the merchants in the context, so they should be updated on this user too
        merchants = [[[NSArray alloc] initWithArray:[user getMyMerchants]] sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    filteredMerchants = [NSMutableArray arrayWithCapacity:[merchants count]];
    filteredMerchants = [NSMutableArray arrayWithArray:merchants];
}

/*
 *  Originally, this logic seemed complicated so I pulled this into this
 *  method... but not needed now.
 */
-(LocationUpdateType) getLocationUpdateType
{
    int type;
    if (_customerLocation == nil)
    {
        type = LOCATION_UNAVAILABLE;
    }
    else if (locationChanged || proximityChanged)
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
