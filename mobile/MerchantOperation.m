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
#import "LocationHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import <CoreLocation/CoreLocation.h>

@implementation MerchantOperation

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
        
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        CLLocation *location = [LocationHelper sharedInstance].lastLocation;
        NSManagedObjectContext *context = [self getContext];
        
        NSError *error;
        BOOL result = [ttMerchant getMerchants:customer withLocation:location context:context error:&error];
        
        if (self.delegate)
        {
            
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            [delegateResponse setObject:[NSNumber numberWithBool:(location!=nil)] forKey:DELEGATE_RESPONSE_LOCATION_ENABLED];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(merchantOperationComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
    }
    
}

@end
