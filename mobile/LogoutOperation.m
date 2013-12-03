//
//  LogoutOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LogoutOperation.h"
#import "Talool-API/ttCustomer.h"
#import "FacebookSDK/FacebookSDK.h"
#import "CustomerHelper.h"

@implementation LogoutOperation

- (id) initWithDelegate:(id<OperationQueueDelegate>)d
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
        
        NSError *error;
        BOOL result = [ttCustomer logoutUser:[self getContext] error:&error];
        
        if (self.delegate)
        {
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(logoutComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
    }
    
}

@end
