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
#import "DealOfferHelper.h"

@interface MerchantSearchHelper ()

- (void) filterMerchants;

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL locationManagerEnabled;
@property BOOL fetching;

@end

@implementation MerchantSearchHelper

@synthesize merchants, filteredMerchants, selectedPredicate, delegate;

+ (MerchantSearchHelper *)sharedInstance
{
    static dispatch_once_t once;
    static MerchantSearchHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    [self initLocationManager];
    
    [self fetchMerchants];
    [self filterMerchants];
    
    return self;
}

- (void) initLocationManager
{
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // is the location service enabled?
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        [tracker sendEventWithCategory:@"APP"
                            withAction:@"LocationServices"
                             withLabel:@"Disabled"
                             withValue:nil];
    }
    
    // is the location service authorized?
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [tracker sendEventWithCategory:@"APP"
                            withAction:@"LocationServices"
                             withLabel:@"Denied"
                             withValue:nil];
    }
    
    _locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
}


#pragma mark -
#pragma mark - Hit the service to update the merchant array

- (void) fetchMerchants
{
    self.fetching = YES;
    if (_locationManagerEnabled)
    {
        [_locationManager startUpdatingLocation];
    }
    else
    {
        [self fetchWithLocation:nil];
    }
    
}

- (void) fetchWithLocation:(CLLocation *)location
{
    if (self.fetching)
    {
        ttCustomer *user = [CustomerHelper getLoggedInUser];
        [user refreshMerchants:location context:[CustomerHelper getContext]];
        merchants = [self sortMerchants:[user getMyMerchants]];
        [self filterMerchants];
        self.fetching = NO;
    }
    
}

- (NSArray *) sortMerchants:(NSArray *)unsortedMerchants
{
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    return [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark -
#pragma mark - Filter the merchant array based on the predicate and distance
- (void) filterMerchants
{
    
    if ([merchants count]== 0)
    {
        filteredMerchants = merchants;
    }
    else
    {
        // optional filter based on category or favorites
        if (selectedPredicate == nil)
        {
            // show all merchants
            filteredMerchants = [NSMutableArray arrayWithArray:merchants];
        }
        else
        {
            // filter merchants
            filteredMerchants = [NSMutableArray arrayWithArray:[merchants filteredArrayUsingPredicate:selectedPredicate]];
        }
    }
    
    // Send the new array to the delegate
    [delegate merchantSetChanged:filteredMerchants sender:self];
}

#pragma mark -
#pragma mark - MerchantFilterDelegate methods

- (void)filterChanged:(NSPredicate *)filter sender:(id)sender
{
    selectedPredicate = filter;
    [self filterMerchants];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    if (_locationManagerEnabled == NO)
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            // we were just authorized, so update the list
            _locationManagerEnabled = YES;
        }
    }
    
    if (newLocation && self.fetching)
    {
        [_locationManager stopUpdatingLocation];
        [self fetchWithLocation:newLocation];
        
        // This is a bit of a hack, but in order to reduce the load on the device and improve perf
        // the DealOfferHelper relies on this objects location manager
        if ([DealOfferHelper sharedInstance].closestBook==nil)
        {
            [[DealOfferHelper sharedInstance] locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
        }
    }
    if (newLocation || !self.fetching)
    {
        [_locationManager stopUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    NSLog(@"location error: %@", error.localizedDescription);
    [self fetchWithLocation:nil];
    [_locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    _locationManagerEnabled = (status == kCLAuthorizationStatusAuthorized);
}


@end
