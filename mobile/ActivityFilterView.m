//
//  ActivityFilterView.m
//  Talool
//
//  Created by Douglas McCuen on 6/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityFilterView.h"
#import "ActivityStreamHelper.h"

@implementation ActivityFilterView

@synthesize filterControl, delegate, activityHelper;

- (id)initWithFrame:(CGRect)frame activityStreamDelegate:(id<ActivityStreamDelegate>)streamDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"ActivityFilterView" owner:self options:nil];
        
        activityHelper = [[ActivityStreamHelper alloc] initWithDelegate:streamDelegate];
        [self setDelegate:activityHelper];
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) fetchActivities
{
    [delegate fetchActivities];
}

- (void) categoryToggled
{
    
}

@end
