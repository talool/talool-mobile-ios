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
        
        [self reset];
        
    }
    return self;
}

/*
 *  This gets called when the view loads and after a new users logs in.
 */
- (void)reset
{
    [self loadProducts];
    
    closestBook=nil;
    closestProduct=nil;
    closestProductId=nil;
    
}

-(void) loadProducts
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
    
}

-(void) setLocationAsBoulder
{
    closestBook = boulderBook;
    closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER];
    closestProductId = PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER;
    
    NSError *error;
    closestDeals = [closestBook getDeals:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
}

-(void) setLocationAsVancouver
{
    closestBook = vancouverBook;
    closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER];
    closestProductId = PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER;
    
    
}

-(void) setSelectedBook
{
    if (boulderBook==nil || vancouverBook==nil)
    {
        [self loadProducts];
    }
    else if (closestProductId!=nil)
    {
        closestProduct = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:closestProductId];
        if ([closestProductId isEqual:PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER])
        {
            closestBook = boulderBook;
        }
        else
        {
            closestBook = vancouverBook;
        }
        NSError *error;
        closestDeals = [closestBook getDeals:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    [self setClosestLocation:newLocation];
    
}



@end
