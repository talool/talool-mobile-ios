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

@implementation BaseSearchViewController

@synthesize filterControl, merchantFilterDelegate, proximitySliderDelegate, isExplore;
@synthesize customer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isExplore = NO; // the ExploreViewController needs to override this
	
    self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(10.0, 15.0, 296.0, 40.0)];
    [self.view addSubview:self.filterControl];
    [self.filterControl addTarget:self action:@selector(filterMerchants:) forControlEvents:UIControlEventValueChanged];
    
    float defaultProximityInMiles = 100.0;
    [self updateProximityLabel:defaultProximityInMiles];
    [distanceSlider setMaximumValue:200.0];
    [distanceSlider setMinimumValue:2.0];
    [distanceSlider setValue:defaultProximityInMiles];
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
        [tableViewController setSearchMode:isExplore];
        tableViewController.filterIndex = filterControl.selectedSegmentIndex;
        tableViewController.proximity = [[[NSNumber alloc] initWithFloat:distanceSlider.value] intValue];
        self.proximitySliderDelegate = tableViewController;
        self.merchantFilterDelegate = tableViewController;
    }
}

- (void) filterMerchants:(id)sender
{
    [merchantFilterDelegate filterChanged:filterControl.selectedSegmentIndex sender:self];
}

- (void) filterMerchantsByProximity:(id)sender
{
    [proximitySliderDelegate proximityChanged:distanceSlider.value sender:sender];
}

- (void) updateProximityLabel:(float) miles
{
    NSNumber *prox = [[NSNumber alloc] initWithFloat:miles];
    distanceLabel.text = [NSString localizedStringWithFormat:@"Proximity: %d miles", [prox intValue]];
}

- (IBAction)proximitySliderValueChanged:(id)sender
{
    // this only changes the label
    [self updateProximityLabel:distanceSlider.value];
}

@end
