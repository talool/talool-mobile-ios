//
//  ActivityFilterView.m
//  Talool
//
//  Created by Douglas McCuen on 6/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityFilterView.h"
#import "ActivityStreamHelper.h"
#import "ActivityFilterControl.h"
#import "TextureHelper.h"
#import "TaloolColor.h"

@implementation ActivityFilterView

@synthesize filterControl, delegate, activityHelper;

- (id)initWithFrame:(CGRect)frame activityStreamDelegate:(id<ActivityStreamDelegate>)streamDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"ActivityFilterView" owner:self options:nil];
        
        self.filterControl = [[ActivityFilterControl alloc] initWithFrame:CGRectMake(12.0, 12.0, 296.0, 35.0)];
        //self.filterControl = [[ActivityFilterControl alloc] initWithFrame:CGRectMake(12.0, 40.0, 296.0, 35.0)];
        [view addSubview:self.filterControl];
        [self.filterControl addTarget:self action:@selector(filterToggled) forControlEvents:UIControlEventValueChanged];
        
        activityHelper = [[ActivityStreamHelper alloc] initWithDelegate:streamDelegate];
        [self setDelegate:activityHelper];
        
        texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:CGSizeMake(320.0, 90.0)];
        [texture setAlpha:0.15];
        
        [self addSubview:view];
        
        [self updateFilterLabel:self.filterControl.selectedSegmentIndex];
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

- (void) filterToggled
{
    NSPredicate *predicate = [self.filterControl getPredicateAtSelectedIndex];
    [self updateFilterLabel:self.filterControl.selectedSegmentIndex];
    [self.delegate filterChanged:predicate sender:self];
}

- (void) updateFilterLabel:(NSInteger) index
{
    switch (index) {
        case 1:
            prompt.text = @"Showing gifts sent and received";
            break;
            
        case 2:
            prompt.text = @"Showing packs purchased and deals redeemed";
            break;
            
        case 3:
            prompt.text = @"Showing your friends' activity";
            break;
            
        case 4:
            prompt.text = @"Showing messages from merchants and Talool";
            break;
            
        default:
            prompt.text = @"Filter your activities with local merchants";
            break;
    }
}

@end
