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

@interface DealOfferHelper()

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL locationManagerEnabled;

@end

@implementation DealOfferHelper

@synthesize dealOffers, boulderBook, vancouverBook, closestBook, closestProduct, closestProductId;

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
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
        
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
        
        _locationManagerEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
        
    }
    return self;
}

- (ttDealOffer *) getClosestDealOffer
{
    return closestBook;
}

- (SKProduct *) getClosestProduct
{
    return closestProduct;
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
    
    if (closestProduct != nil && closestBook != nil)
    {
        //NSLog(@"DEBUG::: got the closest book (%@) and product (%@)",closestBook.title, closestProduct.productIdentifier);
        [_locationManager stopUpdatingLocation];
    }
}

-(void) setLocationAsBoulder
{
    closestBook = boulderBook;
    closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER];
    closestProductId = PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER;
}

-(void) setLocationAsVancouver
{
    closestBook = vancouverBook;
    closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER];
    closestProductId = PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER;
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
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:@"close"
                                              otherButtonTitles:nil];
	[errorView show];
}


@end
