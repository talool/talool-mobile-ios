//
//  DealOfferHelper.m
//  Talool
//
//  Created by Douglas McCuen on 7/8/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferHelper.h"
#import "CustomerHelper.h"
#import "TaloolIAPHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "talool-api-ios/GAI.h"

@interface DealOfferHelper()

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL locationManagerEnabled;

@end

@implementation DealOfferHelper

@synthesize dealOffers, boulderBook, vancouverBook, closestBook, closestProduct, closestProductId, closestDeals;

+ (DealOfferHelper *)sharedInstance
{
    static dispatch_once_t once;
    static DealOfferHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    if ((self = [super init])) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        
        [self reset];
        
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
        
        _locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
        
    }
    return self;
}

/*
 *  This gets called when the view loads and after a new users logs in.
 */
- (void)reset
{
    // load the products
    [[TaloolIAPHelper sharedInstance] requestProductsWithCompletionHandler:nil];
    
    // Load all deal offers
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *err = nil;
    dealOffers = [ttDealOffer getDealOffers:customer context:[CustomerHelper getContext] error:&err];
    
    // Pluck out the Payback books
    for (int i=0; i<[dealOffers count]; i++)
    {
        ttDealOffer *dOff = [dealOffers objectAtIndex:i];
        if ([dOff.dealOfferId isEqualToString:DEAL_OFFER_ID_PAYBACK_BOULDER])
        {
            boulderBook = dOff;
        }
        else if ([dOff.dealOfferId isEqualToString:DEAL_OFFER_ID_PAYBACK_VANCOUVER])
        {
            vancouverBook = dOff;
        }
    }
    
    [_locationManager startUpdatingLocation];
}

- (ttDealOffer *) getClosestDealOffer
{
    return closestBook;
}

- (SKProduct *) getClosestProduct
{
    return closestProduct;
}

- (NSArray *) getClosestDeals
{
    return closestDeals;
}

- (void) setClosestLocation:(CLLocation *)location
{
    if (location==nil || boulderBook == nil) return;

    //NSLog(@"getting distance from %f %f",location.coordinate.latitude, location.coordinate.longitude);
    
    CLLocation *boulder = [[CLLocation alloc] initWithLatitude:BOULDER_LATITUDE longitude:BOULDER_LONGITUDE];
    CLLocation *vancouver = [[CLLocation alloc] initWithLatitude:VANCOUVER_LATITUDE longitude:VANCOUVER_LONGITUDE];
    CLLocationDistance distanceToBoulder = [location distanceFromLocation:boulder];
    CLLocationDistance distanceToVancouver = [location distanceFromLocation:vancouver];
    
    if (distanceToBoulder < distanceToVancouver)
    {
        [self setLocationAsBoulder];
    }
    else
    {
        [self setLocationAsVancouver];
    }
    
    if (closestBook != nil)
    {
        //NSLog(@"DEBUG::: got the closest book (%@) and product (%@)",closestBook.title, closestProduct.productIdentifier);
        [_locationManager stopUpdatingLocation];
    }
}

-(void) setLocationAsBoulder
{
    if (boulderBook==nil)
    {
        [self reset];
    }
    closestBook = boulderBook;
    closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER];
    closestProductId = PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER;
    
    NSError *error;
    closestDeals = [closestBook getDeals:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
}

-(void) setLocationAsVancouver
{
    if (vancouverBook==nil)
    {
        [self reset];
    }
    closestBook = vancouverBook;
    closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER];
    closestProductId = PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER;
    
    NSError *error;
    closestDeals = [closestBook getDeals:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    [self setClosestLocation:newLocation];
    
    if (_locationManagerEnabled == NO)
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            // we were just authorized, so update the list
            _locationManagerEnabled = YES;
            [self setClosestLocation:newLocation];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"APP"
                        withAction:@"ClosestDealOffer"
                         withLabel:@"Fail:location_error"
                         withValue:nil];
}


@end
