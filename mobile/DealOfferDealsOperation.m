//
//  DealOfferDealsOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferDealsOperation.h"
#import "CustomerHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttDealOffer.h"

@implementation DealOfferDealsOperation

- (id)initWithOffer:(ttDealOffer *)offer delegate:(id)d
{
    if (self = [super init])
    {
        self.dealOffer = offer;
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        if ([CustomerHelper getLoggedInUser] == nil) return;
        
        NSManagedObjectContext *context = [self getContext];
        NSError *error;
        [self.dealOffer getDeals:[CustomerHelper getLoggedInUser] context:context error:&error];
        
        // TODO move this to ttDealOffer
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after getDeals: %@ %@",saveError, [saveError userInfo]);
        }
        
        if (self.delegate)
        {
            //[self.delegate dealOfferDealsOperationComplete:self];
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(dealOfferDealsOperationComplete:))
                                                        withObject:nil
                                                     waitUntilDone:NO];
        }
        
    }
    
}

@end
