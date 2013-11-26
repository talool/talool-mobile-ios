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
        
        if ([self isCancelled]) return;
        if ([CustomerHelper getLoggedInUser] == nil) return;
        
        NSError *error;
        CLLocation *loc = [MerchantSearchHelper sharedInstance].lastLocation;
        NSManagedObjectContext *context = [self getContext];
        if (![[CustomerHelper getLoggedInUser] fetchDealOfferSummaries:loc context:context error:&error])
        {
            NSLog(@"geo summary request failed.  HANDLE THE ERROR!");
        }
        
        // TODO move this to ttCustomer
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after fetchDealOfferSummaries: %@ %@",saveError, [saveError userInfo]);
        }
        
        if (self.delegate)
        {
            //[self.delegate dealOfferOperationComplete:self];
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(dealOfferOperationComplete:))
                                                        withObject:nil
                                                     waitUntilDone:NO];
        }
        
    }
    
}

@end
