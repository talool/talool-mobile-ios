//
//  ActivityStreamHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityStreamHelper.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttActivity.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"

@implementation ActivityStreamHelper

@synthesize activities, delegate, activityMonitor, selectedPredicate;

- (id) initWithDelegate:(id<ActivityStreamDelegate>)streamDelegate
{
    self = [super init];
    
    [self setDelegate:streamDelegate];
     
    return self;
}

- (void) startPollingActivity
{
    [self fetchActivities];
    
    NSNumber *interval = [NSNumber numberWithInt:ACTIVITY_MONITOR_INTERVAL_IN_SECONDS];
    
    activityMonitor = [NSTimer scheduledTimerWithTimeInterval:[interval floatValue]
                                                       target:self
                                                     selector:@selector(fetchActivities)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void) stopPollingActivity
{
    [activityMonitor invalidate];
}

#pragma mark -
#pragma mark - Filter the activities array based on the predicate
- (void) filterActivities
{
    
    if ([activities count]==0)
    {
        return;
    }
    
    NSArray *tempArray;
    
    // optional filter based on category or favorites
    if (selectedPredicate == nil)
    {
        // show all merchants
        tempArray = [NSMutableArray arrayWithArray:activities];
    }
    else
    {
        // filter merchants
        tempArray = [NSMutableArray arrayWithArray:[activities filteredArrayUsingPredicate:selectedPredicate]];
    }
    
    // Send the new array to the delegate
    [delegate activitySetChanged:tempArray sender:self];
}

#pragma mark -
#pragma mark - ActivityFilterDelegate methods

- (void) fetchActivities
{
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    NSError *error;
    activities = [user getActivities:[CustomerHelper getContext] error:&error];
    [self filterActivities];
    
    // preload any gifts too
    int openActivities = 0;
    for (int i=0; i<[activities count]; i++)
    {
        ttActivity *act = [activities objectAtIndex:i];
        if ([act isWelcomeEvent] ||
            [act isTaloolReachEvent] ||
            [act isMerchantReachEvent] ||
            [act isFacebookReceiveGiftEvent] ||
            [act isEmailReceiveGiftEvent])
        {
            if (![act isClosed])
            {
                openActivities++;
            }
        }
    }
    [delegate openActivityCountChanged:openActivities sender:self];
}


- (void)filterChanged:(NSPredicate *)filter sender:(id)sender
{
    selectedPredicate = filter;
    [self filterActivities];
}

@end
