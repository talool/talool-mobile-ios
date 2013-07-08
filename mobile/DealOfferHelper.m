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


@implementation DealOfferHelper

@synthesize dealOffers, boulderBook, vancouverBook;

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
        
    }
    return self;
}

- (ttDealOffer *) getClosestDealOffer
{
    #warning @"get the closest payback book to the user"
    return boulderBook;
}

- (SKProduct *) getClosestProduct
{
    #warning @"get the closest product to the user"
    return [[TaloolIAPHelper sharedInstance] getProductForIdentifier:PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER];
}

@end
