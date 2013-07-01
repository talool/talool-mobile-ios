//
//  MerchantSearchView.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantSearchView.h"
#import "MerchantFilterControl.h"
#import "MerchantSearchHelper.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "TaloolColor.h"
#import "TextureHelper.h"

@implementation MerchantSearchView

@synthesize delegate, searchHelper;

- (id)initWithFrame:(CGRect)frame isExplore:(BOOL)explore merchantSearchDelegate:(id<MerchantSearchDelegate>)searchDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isExplore = explore;
        
        [[NSBundle mainBundle] loadNibNamed:@"MerchantSearchView" owner:self options:nil];
        
        //self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(12.0, 40.0, 296.0, 35.0)];
        self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(12.0, 12.0, 296.0, 35.0)];
        
        [view addSubview:self.filterControl];
        [self.filterControl addTarget:self action:@selector(categoryToggled) forControlEvents:UIControlEventValueChanged];
        
        if (explore)
        {
            [self.filterControl removeSegmentAtIndex:1 animated:NO];
        }
        
        [self updateProximityLabel:DEFAULT_PROXIMITY];
        [distanceSlider setMaximumValue:MAX_PROXIMITY];
        [distanceSlider setMinimumValue:MIN_PROXIMITY];
        [distanceSlider setValue:DEFAULT_PROXIMITY];
        [distanceSlider addTarget:self action:@selector(proximityChanged) forControlEvents:UIControlEventTouchUpInside];
        [distanceSlider addTarget:self action:@selector(proximityChanged) forControlEvents:UIControlEventTouchUpOutside];
        
        searchHelper = [[MerchantSearchHelper alloc] initWithDelegate:searchDelegate searchMode:explore];
        [self setDelegate:searchHelper];
        
        texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:CGSizeMake(320.0, 90.0)];
        [texture setAlpha:0.15];
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) fetchMerchants
{
    [delegate fetchMerchants];
}

#pragma mark -
#pragma mark - Slider moved so update label

- (IBAction)proximitySliderValueChanged:(id)sender
{
    NSNumber *prox = [[NSNumber alloc] initWithFloat:distanceSlider.value];
    [self updateProximityLabel:[prox intValue]];
}

- (void) updateProximityLabel:(int)miles
{
    if (miles == INFINITE_PROXIMITY || miles == MAX_PROXIMITY)
    {
        distanceLabel.text = @"Proximity: infinite";
    }
    else
    {
        distanceLabel.text = [NSString localizedStringWithFormat:@"Proximity: %d miles", miles];
    }
}

#pragma mark -
#pragma mark - Selectors for the Controls

- (void) categoryToggled
{
    NSPredicate *predicate = [self.filterControl getPredicateAtSelectedIndex:self.isExplore];
    [self.delegate filterChanged:predicate sender:self];
}

- (void) proximityChanged
{
    [self.delegate proximityChanged:distanceSlider.value sender:self];
}
@end
