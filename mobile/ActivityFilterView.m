//
//  ActivityFilterView.m
//  Talool
//
//  Created by Douglas McCuen on 6/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityFilterView.h"
#import "ActivityFilterControl.h"
#import "TextureHelper.h"
#import "TaloolColor.h"

@implementation ActivityFilterView

@synthesize filterControl, delegate;

- (id)initWithFrame:(CGRect)frame activityFilterDelegate:(id<ActivityFilterDelegate>)d
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"ActivityFilterView" owner:self options:nil];
        
        self.filterControl = [[ActivityFilterControl alloc] initWithFrame:CGRectMake(7.0, 7.0, 306.0, 35.0)];
        [view addSubview:self.filterControl];
        [self.filterControl addTarget:self action:@selector(filterToggled) forControlEvents:UIControlEventValueChanged];
        
        [self setDelegate:d];
        
        [self addSubview:view];
        
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) filterToggled
{
    NSPredicate *predicate = [self.filterControl getPredicateAtSelectedIndex];
    [self.delegate filterChanged:predicate sender:self];
}


@end
