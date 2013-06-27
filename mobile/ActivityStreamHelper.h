//
//  ActivityStreamHelper.h
//  Talool
//
//  Created by Douglas McCuen on 6/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaloolProtocols.h"


#define ACTIVITY_MONITOR_INTERVAL_IN_SECONDS 15.0

@interface ActivityStreamHelper : NSObject<ActivityFilterDelegate>

@property (retain, nonatomic) NSArray *activities;
@property (retain, nonatomic) id<ActivityStreamDelegate> delegate;
@property (retain, nonatomic) NSTimer *activityMonitor;
@property (retain, nonatomic) NSPredicate *selectedPredicate;

- (void) fetchActivities;
- (void) stopPollingActivity;
- (void) startPollingActivity;
- (id) initWithDelegate:(id<ActivityStreamDelegate>)streamDelegate;

@end
