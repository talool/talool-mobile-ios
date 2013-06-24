//
//  ActivityFilterView.h
//  Talool
//
//  Created by Douglas McCuen on 6/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ActivityFilterControl, ActivityStreamHelper;

@interface ActivityFilterView : UIView
{
    IBOutlet UIView *view;
}

- (void) categoryToggled;
- (void) fetchActivities;

@property (strong, nonatomic) ActivityFilterControl *filterControl;
@property (retain, nonatomic) id<ActivityFilterDelegate> delegate;
@property (retain, nonatomic) ActivityStreamHelper *activityHelper;

- (id)initWithFrame:(CGRect)frame activityStreamDelegate:(id<ActivityStreamDelegate>)streamDelegate;

@end
