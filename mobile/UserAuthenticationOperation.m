//
//  UserAuthenticationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "UserAuthenticationOperation.h"
#import "Talool-API/ttCustomer.h"

@implementation UserAuthenticationOperation

- (id) initWithUser:(NSString *)e password:(NSString *)p delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.email = e;
        self.password = p;
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        NSMutableDictionary *delegateResponse;
        
        NSError *error;
        NSManagedObjectContext *context = [self getContext];
        BOOL result = [ttCustomer authenticate:self.email password:self.password context:context error:&error];
        
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
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(userAuthComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
        
    }
    
}

@end
