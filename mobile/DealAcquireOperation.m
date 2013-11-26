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
#import "CustomerHelper.h"

@implementation DealAcquireOperation

@synthesize merchant;

- (id)initWithMerchant:(ttMerchant *)m delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.merchant = m;
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) {
            [self sendCompletionMessage];
            return;
        }
        if ([CustomerHelper getLoggedInUser] == nil) return;

        NSError *error;
        NSManagedObjectContext *context = [self getContext];
        [[CustomerHelper getLoggedInUser] refreshMyDealsForMerchant:merchant
                                                            context:context
                                                              error:&error];
        
        // TODO move this to ttCustomer
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after refreshMyDealsForMerchant: %@ %@",saveError, [saveError userInfo]);
        }
        
        [self sendCompletionMessage];
    }
    
}

- (void) sendCompletionMessage
{
    if (self.delegate)
    {
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(dealAcquireOperationComplete:)) withObject:self waitUntilDone:NO];
        NSLog(@"sent DAO completion message for %@", self.merchant.name);
    }
}

@end
