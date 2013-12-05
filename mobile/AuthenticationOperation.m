//
//  AuthenticationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AuthenticationOperation.h"
#import "AppDelegate.h"
#import <TaloolTabBarController.h>
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttCategory.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttActivity.h"
#import "CategoryHelper.h"
#import <LocationHelper.h>
#import "OperationQueueManager.h"

@implementation AuthenticationOperation

- (id)init
{
    self = [super init];
    return self;
}

- (NSMutableDictionary *) setUpUser:(NSError **)error
{
    NSMutableDictionary *result;
    BOOL success = NO;
    
    NSManagedObjectContext *context = [self getContext];
    ttCustomer *customer = [ttCustomer getLoggedInUser:context];
    if (customer)
    {
        if ([ttCategory getCategories:customer context:context error:error])
        {
            if ([ttMerchant getMerchants:customer withLocation:nil context:context error:error])
            {
                if ([ttMerchant getFavoriteMerchants:customer context:context error:error])
                {
                    NSDictionary *activityResponse = [ttActivity getActivities:customer context:context error:error];
                    NSNumber *activityResult = [activityResponse objectForKey:@"success"];
                    if ([activityResult boolValue])
                    {
                        result = [NSMutableDictionary dictionaryWithDictionary:activityResponse];
                        
                        [(NSObject *)[CategoryHelper sharedInstance] performSelectorOnMainThread:(@selector(reset))
                                                                                      withObject:nil
                                                                                   waitUntilDone:NO];
                        
                        // init the location helper to start monitoring
                        [LocationHelper sharedInstance];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFICATION object:result userInfo:result];
                        
                        success = YES;
                    }
                    else
                    {
                        NSLog(@"failed to get activities.");
                    }
                }
                else
                {
                    NSLog(@"failed to get favs.");
                }
            }
            else
            {
                NSLog(@"failed to get merchants.");
            }
        }
        else
        {
            NSLog(@"failed to get categories.");
        }
    }
    
    if (!success)
    {
        result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:success] forKey:DELEGATE_RESPONSE_SUCCESS];
    }
    
    return result;
}

@end
