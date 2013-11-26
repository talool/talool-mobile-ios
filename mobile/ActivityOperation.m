//
//  ActivityOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityOperation.h"
#import "CustomerHelper.h"
#import "ActivityStreamHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttActivity.h"

@implementation ActivityOperation

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        ttCustomer *user = [CustomerHelper getLoggedInUser];
        
        if (!user) return;
        
        NSError *error;
        NSArray *activities = [user getActivities:[CustomerHelper getContext] error:&error];
        
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
        
#warning @"We need to get back on the main thread to handle those activites"
        //[[ActivityStreamHelper sharedInstance] handleFetchedActivities:activities openCount:openActivities];
        //[(NSObject *)self.delegate performSelectorOnMainThread:(@selector(completeUserLogout:)) withObject:nil waitUntilDone:NO];
    }
    
}

@end
