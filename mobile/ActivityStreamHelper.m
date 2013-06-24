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
#import "talool-api-ios/TaloolFrameworkHelper.h"

@implementation ActivityStreamHelper

@synthesize activities, delegate, activityMonitor;

- (id) initWithDelegate:(id<ActivityStreamDelegate>)streamDelegate
{
    self = [super init];
    
    [self setDelegate:streamDelegate];
     
    return self;
}

- (void) startPollingActivity
{
    NSLog(@"Start activity monitor timer");
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
    NSLog(@"Stop activity monitor timer");
    [activityMonitor invalidate];
}

#pragma mark -
#pragma mark - ActivityFilterDelegate methods

- (void) fetchActivities
{
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    NSError *error;
    activities = [user getGifts:[CustomerHelper getContext] error:&error];
    
    //NSLog(@"DEBUG::: Activies: found %lu activities",(unsigned long)[activities count]);
    
    // Send the new array to the delegate
    [delegate activitySetChanged:activities sender:self];
}

/*
 - (void) checkForGifts:(id)sender
 {
 NSError *error;
 NSArray *gifts = [[CustomerHelper getLoggedInUser] getGifts:[CustomerHelper getContext] error:&error];
 // TODO if the user gets a bunch of gifts, we should show a table view
 if ([gifts count]>0)
 {
 // create the modal screen and show it
 AcceptGiftViewController *giftVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptGiftViewController"];
 giftVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
 giftVC.gift = [gifts objectAtIndex:0];
 [self presentViewController:giftVC animated:YES completion:nil];
 
 [giftVC setGiftDelegate:self];
 }
 }
 */

- (void)filterChanged:(NSPredicate *)filter sender:(id)sender
{
    
}

@end
