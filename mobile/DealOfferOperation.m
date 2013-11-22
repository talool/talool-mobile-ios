//
//  DealOfferOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferOperation.h"
#import "CustomerHelper.h"
#import "MerchantSearchHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttDealOffer.h"

@implementation DealOfferOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        NSLog(@"DealOfferOperation started");
        
        if ([self isCancelled]) return;
        if ([CustomerHelper getLoggedInUser] == nil) return;
        
        NSError *error;
        CLLocation *loc = [MerchantSearchHelper sharedInstance].lastLocation;
        if (![[CustomerHelper getLoggedInUser] fetchDealOfferSummaries:loc context:[CustomerHelper getContext] error:&error])
        {
            NSLog(@"geo summary request failed.  HANDLE THE ERROR!");
        }
        NSLog(@"DealOfferOperation executed fetchDealOfferSummaries");
        
        
    }
    
}

@end
