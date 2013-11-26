//
//  AuthenticationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AuthenticationOperation.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttCategory.h"
#import "CategoryHelper.h"

@implementation AuthenticationOperation

- (id)init
{
    self = [super init];
    return self;
}

- (BOOL) setUpUser:(NSError **)error
{
    NSManagedObjectContext *context = [self getContext];
    ttCustomer *customer = [ttCustomer getLoggedInUser:context];
    if (customer)
    {
        [ttCategory getCategories:customer context:context];
        
        // refresh merchants without location
        [customer refreshMerchants:nil context:context];
        
        [customer refreshFavoriteMerchants:context];
        
        // TODO move this to tt objects
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after getCategories: %@ %@",saveError, [saveError userInfo]);
        }
        
        [(NSObject *)[CategoryHelper sharedInstance] performSelectorOnMainThread:(@selector(reset))
                                                                      withObject:nil
                                                                   waitUntilDone:NO];
        return YES;
    }
    
    // Create a new error object to message that we need to register this user
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    NSString *errorDetails = @"We were unable to prepare your account (Didn't find user in context).";
    [details setValue:errorDetails forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"PostAuthenticationSetUp"
                                code:AuthenticationErrorCode_SETUP_FAILED
                            userInfo:details];
    
    return NO;
}

@end
