//
//  DealOfferHelper.h
//  Talool
//
//  Created by Douglas McCuen on 7/8/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#warning @"environment specific deal offer ids";
#define DEAL_OFFER_ID_PAYBACK_BOULDER        @"e11dcc50-3ee1-477d-9e2d-ab99f0c28675"
#define DEAL_OFFER_ID_PAYBACK_VANCOUVER      @"231d6a36-1a40-44c6-ba25-402f42d05f6d"

#define BOULDER_LATITUDE        40.0150
#define BOULDER_LONGITUDE       -105.2700
#define VANCOUVER_LATITUDE      45.6389
#define VANCOUVER_LONGITUDE     -122.6603

@class ttDealOffer, SKProduct;

@interface DealOfferHelper : NSObject<CLLocationManagerDelegate>

+ (DealOfferHelper *)sharedInstance;

@property (strong, nonatomic) NSSet *dealOfferIds;
@property (strong, nonatomic) NSArray *dealOffers;
@property (strong, nonatomic) ttDealOffer *boulderBook;
@property (strong, nonatomic) ttDealOffer *vancouverBook;

@property (strong, nonatomic) ttDealOffer *closestBook;
@property (strong, nonatomic) SKProduct *closestProduct;
@property (strong, nonatomic) NSString *closestProductId;

- (ttDealOffer *) getClosestDealOffer;
- (SKProduct *) getClosestProduct;

-(void) setLocationAsBoulder;
-(void) setLocationAsVancouver;

@end
