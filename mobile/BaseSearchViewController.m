//
//  BaseSearchViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseSearchViewController.h"
#import "MechantTableViewController.h"
#import "MerchantFilterControl.h"
#import "FontAwesomeKit.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"

@interface BaseSearchViewController ()

@end

#define MAX_PROXIMITY 100
#define DEFAULT_PROXIMITY 20
#define MIN_PROXIMITY 1

@implementation BaseSearchViewController

@synthesize filterControl, merchantFilterDelegate, proximitySliderDelegate, isExplore;
@synthesize customer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isExplore = NO; // the ExploreViewController needs to override this
	
    self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(10.0, 15.0, 296.0, 40.0)];
    [self.view addSubview:self.filterControl];
    [self.filterControl addTarget:self action:@selector(filterMerchants:) forControlEvents:UIControlEventValueChanged];
    
    [self updateProximityLabel:DEFAULT_PROXIMITY];
    [distanceSlider setMaximumValue:MAX_PROXIMITY];
    [distanceSlider setMinimumValue:MIN_PROXIMITY];
    [distanceSlider setValue:DEFAULT_PROXIMITY];
    [distanceSlider addTarget:self action:@selector(filterMerchantsByProximity:) forControlEvents:UIControlEventTouchUpInside];
    [distanceSlider addTarget:self action:@selector(filterMerchantsByProximity:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    customer = [CustomerHelper getLoggedInUser];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"myMerchants"] || [[segue identifier] isEqualToString:@"exploreMerchants"]) {
        // Grab the table view when it is embedded in the controller
        MechantTableViewController *tableViewController = [segue destinationViewController];
        [tableViewController setSearchMode:[self getSearchMode]];
        tableViewController.selectedFilter = nil;
        tableViewController.proximity = DEFAULT_PROXIMITY;
        self.proximitySliderDelegate = tableViewController;
        self.merchantFilterDelegate = tableViewController;
    }
}

- (void) filterMerchants:(id)sender
{
    NSPredicate *filter = [self.filterControl getPredicateAtSelectedIndex:isExplore];
    [merchantFilterDelegate filterChanged:filter sender:self];
}

- (void) filterMerchantsByProximity:(id)sender
{
    [proximitySliderDelegate proximityChanged:distanceSlider.value sender:sender];
}

- (void) updateProximityLabel:(float) miles
{
    NSNumber *prox = [[NSNumber alloc] initWithFloat:miles];
    if ([prox intValue] == MAX_PROXIMITY)
    {
        distanceLabel.text = @"Proximity: infinite";
    }
    else
    {
        distanceLabel.text = [NSString localizedStringWithFormat:@"Proximity: %d miles", [prox intValue]];
    }
}

- (IBAction)proximitySliderValueChanged:(id)sender
{
    // this only changes the label
    [self updateProximityLabel:distanceSlider.value];
}

-(Boolean) getSearchMode
{
    return NO;
}

@end
