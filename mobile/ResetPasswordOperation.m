//
//  ResetPasswordOperation.m
//  Talool
//
//  Created by Douglas McCuen on 12/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ResetPasswordOperation.h"
#import "Talool-API/ttCustomer.h"

@implementation ResetPasswordOperation

- (id) initWithPassword:(NSString *)pw customerId:(NSString *)cId changeToken:(NSString *)ct delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.password = pw;
        self.customerId = cId;
        self.changeToken = ct;
    }
    return self;
}


- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        NSMutableDictionary *delegateResponse;
        
        NSError *error;
        BOOL result = [ttCustomer resetPassword:self.customerId
                                       password:self.password
                                           code:self.changeToken
                                        context:[self getContext]
                                          error:&error];
        if (result)
        {
            delegateResponse = [self setUpUser:&error];
            result = [[delegateResponse objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
        }
        
        if (self.delegate)
        {
            if (!delegateResponse)
            {
                delegateResponse = [[NSMutableDictionary alloc] init];
            }
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(passwordResetOperationComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
    }
    
}

@end
