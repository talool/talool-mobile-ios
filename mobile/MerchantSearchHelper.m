//
//  MerchantSearchHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantSearchHelper.h"
#import "CustomerHelper.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface MerchantSearchHelper ()

- (void) filterMerchants;

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL locationManagerEnabled;
@property BOOL fetching;

@end

@implementation MerchantSearchHelper

@synthesize merchants, filteredMerchants, selectedPredicate, delegate, locationManagerStatusKnown, lastLocation;

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
    
    locationManagerStatusKnown = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
    _locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    
}

- (void) promptForLocationServiceAuthorization
{
    _locationManagerEnabled=YES;
    [self fetchMerchants];
    [self filterMerchants];
    locationManagerStatusKnown = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
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
        lastLocation = newLocation;
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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // is the location service enabled?
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"APP"
                                                              action:@"LocationServices"
                                                               label:@"Disabled"
                                                               value:nil] build]];
    }
    
    // is the location service authorized?
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"APP"
                                                              action:@"LocationServices"
                                                               label:@"Denied"
                                                               value:nil] build]];
    }
}


@end
