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
        
        NSError *error = nil;
        NSManagedObjectContext *context = [self getContext];
        [ttCustomer authenticate:self.email password:self.password context:context error:&error];
        
        if (!error)
        {
            [self setUpUser:&error];
        }
        
        
        if (self.delegate)
        {
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(userAuthComplete:))
                                                        withObject:error
                                                     waitUntilDone:NO];
        }
        
    }
    
}

@end
