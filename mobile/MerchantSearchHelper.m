//
//  MerchantSearchHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantSearchHelper.h"
#import "CustomerHelper.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/GAI.h"

@interface MerchantSearchHelper ()

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *customerLocation;
@property (strong, nonatomic) CLLocation *lastLocation;
@property int lastProximity;
@property BOOL locationChanged;
@property BOOL proximityChanged;
@property BOOL locationManagerEnabled;
@property int locationRetryCount;

- (void) filterMerchants;
- (BOOL) fetchMerchantsForSearch;
- (void) fetchMerchantsForUser;
- (int) getProxmitityInMeters;

@end

@implementation MerchantSearchHelper

@synthesize isSearch, merchants, distanceInMiles, selectedPredicate, delegate;
@synthesize lastProximity, proximityChanged, locationChanged,locationManagerEnabled, locationRetryCount;

- (id) initWithDelegate:(id<MerchantSearchDelegate>)searchDelegate searchMode:(BOOL)searchMode
{
    self = [super init];
    
    [self setIsSearch:searchMode];
    [self setDelegate:searchDelegate];
    [self setDistanceInMiles:[[NSNumber alloc] initWithInt:DEFAULT_PROXIMITY]];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _customerLocation = nil;
    _lastLocation = nil;
    locationChanged = YES;
    proximityChanged = YES;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // is the location service enabled?
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        // the user will be prompted to turn them on when the location
        // manager starts up.
        NSLog(@"The user has disabled location services");
        [tracker sendEventWithCategory:@"APP"
                            withAction:@"LocationServices"
                             withLabel:@"Disabled"
                             withValue:nil];
    }
    
    // is the location service authorized?
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        /*
         * TODO
         - message user about why it's needed?
         - flag the user obj, so we can avoid errors?
         */
        NSLog(@"The user has denied the use of their location");
        [tracker sendEventWithCategory:@"APP"
                            withAction:@"LocationServices"
                             withLabel:@"Denied"
                             withValue:nil];
    }
    
    locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    
    [self fetchMerchants];
    
    return self;
}


#pragma mark -
#pragma mark - Hit the service to update the merchant array

- (void) fetchMerchants
{
    if ([self fetchMerchantsForSearch])
    {
        if (!isSearch)
        {
            [self fetchMerchantsForUser];
        }
        [self filterMerchants];
    }
}

- (BOOL) fetchMerchantsForSearch
{
    
    if (locationManagerEnabled)
    {
        if (_customerLocation != nil)
        {
            ttCustomer *user = [CustomerHelper getLoggedInUser];
            NSError *error;
            NSArray *unsortedMerchants = [user getMerchantsByProximity:[self getProxmitityInMeters]
                                                             longitude:_customerLocation.coordinate.longitude
                                                              latitude:_customerLocation.coordinate.latitude
                                                               context:[CustomerHelper getContext]
                                                                 error:&error];
            merchants = [self sortMerchants:unsortedMerchants];
            
            
            //
            // DEBUG
            /*
            for (int i=0; i<[merchants count]; i++) {
                ttMerchant *m = [merchants objectAtIndex:i];
                if ([m.locations count] == 0)
                {
                    NSLog(@"DEBUG::: fetchMerchantsForSearch found no location for merchant: %@",m.name);
                }
                else
                {
                    NSLog(@"DEBUG::: fetchMerchantsForSearch found a distance of %@ for merchant: %@",m.location.distanceInMeters, m.name);
                }
            }
            */
            // END DEBUG
            //
            
            locationRetryCount = 0;
            
            return YES;
        }
        else if (locationRetryCount < 10)
        {
            // Retry with recursion
            [self performSelector:@selector(fetchMerchants) withObject:nil afterDelay:.5];
            locationRetryCount++;
            NSLog(@"DEBUG::: The location manager is enabled, but _customerLocation is nil.  Attempt %d",locationRetryCount);
            
            return NO;
        }
        
        locationRetryCount = 0;
        
    }
    else
    {
        // Can't search by proximity w/o a location, so just return the user's merchants
        return YES;
    }
    
    return NO;
}

- (void) fetchMerchantsForUser
{
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    [user refreshMerchants:[CustomerHelper getContext]];
    [user refreshFavoriteMerchants:[CustomerHelper getContext]];
    merchants = [self sortMerchants:[user getMyMerchants]];
}

- (NSArray *) sortMerchants:(NSArray *)unsortedMerchants
{
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    return [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
}

- (int) getProxmitityInMeters
{
    int prox = [distanceInMiles intValue];
    if (prox == 0 || prox == MAX_PROXIMITY)
    {
        prox = INFINITE_PROXIMITY;
    }
    int proximityInMeters = METERS_PER_MILE * prox;
    
    return proximityInMeters;
}

#pragma mark -
#pragma mark - Filter the merchant array based on the predicate and distance
- (void) filterMerchants
{
    
    if ([merchants count]==0)
    {
        NSLog(@"DEBUG::: no merchants to filter");
        return;
    }
    
    NSArray *tempArray;
    
    // optional filter based on category or favorites
    if (selectedPredicate == nil)
    {
        // show all merchants
        tempArray = [NSMutableArray arrayWithArray:merchants];
    }
    else
    {
        // filter merchants
        tempArray = [NSMutableArray arrayWithArray:[merchants filteredArrayUsingPredicate:selectedPredicate]];
    }
    
    // filter the array based on proximity
    NSPredicate *proximityPredicate = [NSPredicate predicateWithFormat:@"ANY locations.distanceInMeters < %d",[self getProxmitityInMeters]];
    tempArray = [tempArray filteredArrayUsingPredicate:proximityPredicate];
    
    // Send the new array to the delegate
    [delegate merchantSetChanged:tempArray sender:self];
}

#pragma mark -
#pragma mark - MerchantFilterDelegate methods

- (void)filterChanged:(NSPredicate *)filter sender:(id)sender
{
    selectedPredicate = filter;
    [self filterMerchants];
}

- (void)proximityChanged:(float)valueInMiles sender:(id)sender
{
    distanceInMiles = [[NSNumber alloc] initWithFloat:valueInMiles];
    [self filterMerchants];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    _customerLocation = newLocation;
    
    //
    // Calculate distance and push updates as needed
    //
    CLLocationDistance distance = [_customerLocation distanceFromLocation:_lastLocation];
    float distanceMovedInMiles = distance/METERS_PER_MILE;
    float minAsFloat = [[NSNumber numberWithInt:MIN_PROXIMITY_CHANGE_IN_MILES] floatValue];
    if (distanceMovedInMiles > minAsFloat)
    {
        // fetch the merchants again to update the distances
        [self fetchMerchantsForSearch];
        [self filterMerchants];
    }
    
    if (locationManagerEnabled == NO)
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            // we were just authorized, so update the list
            locationManagerEnabled = YES;
            [self fetchMerchantsForSearch];
            [self filterMerchants];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"APP"
                        withAction:@"MerchantSearchByProximity"
                         withLabel:@"Fail:location_error"
                         withValue:nil];

}

@end
