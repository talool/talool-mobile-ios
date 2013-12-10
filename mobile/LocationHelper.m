//
//  LocationHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LocationHelper.h"
#import "CustomerHelper.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface LocationHelper ()

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL locationManagerEnabled;

@end

@implementation LocationHelper

@synthesize locationManagerStatusKnown, lastLocation;

+ (LocationHelper *)sharedInstance
{
    static dispatch_once_t once;
    static LocationHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    locationManagerStatusKnown = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
    _locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    
    if (_locationManagerEnabled)
    {
        [_locationManager startUpdatingLocation];
    }
    
    return self;
}

- (void) promptForLocationServiceAuthorization
{
    _locationManagerEnabled=YES;
    [_locationManager startUpdatingLocation];
    locationManagerStatusKnown = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
    _locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    
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
    
    if (newLocation)
    {
        lastLocation = newLocation;
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    NSLog(@"location error: %@", error.localizedDescription);
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
