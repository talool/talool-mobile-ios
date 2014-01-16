//
//  RedeemOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RedeemOperation.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "LocationHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttMerchant.h"
#import <CoreLocation/CoreLocation.h>

@implementation RedeemOperation

- (id)initWithDealAcquireId:(NSString *)daId delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.dealAcquireId = daId;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        if (!customer) return;
        
        NSError *error;
        NSManagedObjectContext *context = [self getContext];
        ttDealAcquire *deal = [ttDealAcquire fetchDealAcquireById:self.dealAcquireId context:context];
        CLLocation *location = [LocationHelper sharedInstance].lastLocation;

        BOOL result = [deal redeemHere:customer
                              latitude:location.coordinate.latitude
                             longitude:location.coordinate.longitude
                                 error:&error
                               context:context];
        
        if (result)
        {
            [FacebookHelper postOGRedeemAction:(ttDeal *)deal.deal atLocation:deal.deal.merchant.closestLocation];
        }
        
        if (self.delegate)
        {
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(redeemOperationComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
    }
}

@end


