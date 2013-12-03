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
        
        NSManagedObjectContext *context = [self getContext];
        NSError *error;
        BOOL result = [self.dealOffer getDeals:[CustomerHelper getLoggedInUser] context:context error:&error];
        
        if (self.delegate)
        {
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(dealOfferDealsOperationComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
        
    }
    
}

@end
