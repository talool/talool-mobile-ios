//
//  MerchantOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantOperation.h"
#import "OperationQueueManager.h"
#import "CustomerHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"

@implementation MerchantOperation

@synthesize location;

- (id)initWithLocation:(CLLocation *)loc delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.location = loc;
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        NSManagedObjectContext *context = [self getContext];
        [[CustomerHelper getLoggedInUser] refreshMerchants:location context:context];
        
        // TODO move this to ttCustomer
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after refreshMerchants: %@ %@",saveError, [saveError userInfo]);
        }
        
        if (self.delegate)
        {
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(merchantOperationComplete:))
                                                        withObject:self
                                                     waitUntilDone:NO];
        }
    }
    
}

@end
