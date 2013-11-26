//
//  FacebookAuthenticationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FacebookAuthenticationOperation.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "Talool-API/ttCustomer.h"

@implementation FacebookAuthenticationOperation

- (id) initWithUser:(NSDictionary<FBGraphUser> *)u delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.user = u;
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        NSError *error = nil;
        NSManagedObjectContext *context = [self getContext];
        ttCustomer *customer = [ttCustomer authenticateFacebook:self.user.id
                                              facebookToken:[[[FBSession activeSession] accessTokenData] accessToken]
                                                    context:context
                                                      error:&error];
        if (!error && !customer)
        {
            NSString *email = [self.user objectForKey:@"email"];
            customer = [FacebookHelper createCustomerFromFacebookUser:self.user];
            if ([CustomerHelper isEmailValid:email])
            {
                NSString *password = [ttCustomer nonrandomPassword:email];
                [ttCustomer registerCustomer:customer password:password context:context error:&error];
                
                if (error)
                {
                    // Reg failed so log out of Facebook
                    [[FBSession activeSession] closeAndClearTokenInformation];
                }
                
            }
            else
            {
                // Create a new error object to message that we need to register this user
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                NSString *errorDetails = @"Facebook user is missing a valid email address.";
                [details setValue:errorDetails forKey:NSLocalizedDescriptionKey];
                [details setValue:self.user forKey:@"fbUser"];
                error = [NSError errorWithDomain:@"FacebookAuthentication"
                                            code:FacebookErrorCode_USER_INVALID
                                        userInfo:details];
            }
        }
        else if (error)
        {
            // Reg failed so log out of Facebook
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
        
        if (!error)
        {
            if (![self setUpUser:&error])
            {
                // setup failed so log out of Facebook
                [[FBSession activeSession] closeAndClearTokenInformation];
                // TODO logout of the app
#warning "need to logout the user here"
            }
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
