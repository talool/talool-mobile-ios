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

- (id) initWithUser:(NSDictionary<FBGraphUser> *)u token:(NSString *)t delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.user = u;
        self.delegate = d;
        self.token = t;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        ttCustomer *customer;
        
        NSMutableDictionary *delegateResponse;
        
        NSError *error;
        NSManagedObjectContext *context = [self getContext];
        BOOL result = [ttCustomer authenticateFacebook:self.user.objectID
                                              facebookToken:self.token
                                                    context:context
                                                      error:&error];
        if (!error && !result)
        {
            // Register the user
            NSString *email = [self.user objectForKey:@"email"];
            customer = [FacebookHelper createCustomerFromFacebookUser:self.user context:context];
            if ([CustomerHelper isEmailValid:email])
            {
                NSString *password = [ttCustomer nonrandomPassword:email];
                result = [ttCustomer registerCustomer:customer password:password context:context error:&error];
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
        
        customer = [CustomerHelper getLoggedInUser];
        if (!error && customer)
        {
            delegateResponse = [self setUpUser:&error];
            result = [[delegateResponse objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
            if (!result)
            {
                NSLog(@"user setup failed for Facebook Auth: %@", error);
                // logout of the app
                NSError *err;
                [ttCustomer logoutUser:context error:&err];
            }
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
