//
//  DealAcquireOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealAcquireOperation.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import <Talool-API/ttDealAcquire.h>
#import "CustomerHelper.h"

@implementation DealAcquireOperation

- (id)initWithMerchantId:(NSString *)mid delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.merchantId = mid;
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        if (![CustomerHelper getLoggedInUser])
        {
            return;
        }

        NSError *error;
        NSManagedObjectContext *context = [self getContext];
        
        // make sure we have a merchant from this context
        ttMerchant *merchant = [ttMerchant fetchMerchantById:self.merchantId context:context];
        
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        BOOL result = [ttDealAcquire getDealAcquires:customer forMerchant:merchant context:context error:&error];
        
        if (self.delegate)
        {
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(dealAcquireOperationComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
        
    }
    
}


@end
