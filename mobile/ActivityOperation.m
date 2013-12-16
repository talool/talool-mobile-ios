//
//  ActivityOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityOperation.h"
#import "CustomerHelper.h"
#import "LocationHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttActivity.h"
#import <OperationQueueManager.h>
#import <CoreLocation/CoreLocation.h>

@interface ActivityOperation()

@property id<OperationQueueDelegate> delegate;
@property NSString *activityId;
@property BOOL isActivityAction;

@end

@implementation ActivityOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
    }
    return self;
}

- (id)initWithActivityId:(NSString *)aId delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.activityId = aId;
        self.isActivityAction = YES;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        if (self.isActivityAction)
        {
            [self closeActivity];
        }
        else
        {
            [self getActivities];
        }
    }
    
}

- (void) closeActivity
{
    if ([self isCancelled]) return;
    
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    ttActivity *activity = [ttActivity fetchById:self.activityId context:[self getContext]];
    if (!user || !activity) return;
    
    NSError *error;
    BOOL success = [activity actionTaken:user context:[self getContext] error:&error];
    if (!success || error)
    {
        NSLog(@"failed to get activities: %@",error);
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:success] forKey:DELEGATE_RESPONSE_SUCCESS];
        [delegateResponse setObject:self.activityId forKey:DELEGATE_RESPONSE_OBJECT_ID];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(activityOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

- (void) getActivities
{
    if ([self isCancelled]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"user not logged in" forKey:NSLocalizedDescriptionKey];
        self.error = [[NSError alloc] initWithDomain:@"talool" code:206 userInfo:details];
        return;
    }
    
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    
    if (!user){
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"user not logged in" forKey:NSLocalizedDescriptionKey];
        self.error = [[NSError alloc] initWithDomain:@"talool" code:403 userInfo:details];
        return;
    }
    
    NSError *error;
    NSDictionary *responseData = [ttActivity getActivities:user context:[self getContext] error:&error];
    self.response = responseData;
    self.error = error;
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITY_NOTIFICATION object:self userInfo:self.response];
    });
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [NSMutableDictionary dictionaryWithDictionary:self.response];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(activityOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

@end
