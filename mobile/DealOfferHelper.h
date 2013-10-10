//
//  DealOfferHelper.h
//  Talool
//
//  Created by Douglas McCuen on 7/8/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define DEAL_OFFER_ID_PAYBACK_BOULDER        @"4d54d8ef-febb-4719-b9f0-a73578a41803"    // prod
#define DEAL_OFFER_ID_PAYBACK_VANCOUVER      @"a067de54-d63d-4613-8d60-9d995765cd52"    // prod

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
@property (strong, nonatomic) NSArray *closestDeals;

- (ttDealOffer *) getClosestDealOffer;
- (SKProduct *) getClosestProduct;
- (NSArray *) getClosestDeals;

-(void) setLocationAsBoulder;
-(void) setLocationAsVancouver;
-(void) setSelectedBook;
-(void) reset;

@end
