//
//  ExploreViewController.m
//  Talool
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ExploreViewController.h"
#import "ExploreMerchantsTableViewController.h"
#import "MerchantFilterControl.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "FontAwesomeKit.h"


@implementation ExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.filterControl removeSegmentAtIndex:1 animated:NO];
    UIImage *tabBarIcon = [FontAwesomeKit imageForIcon:FAKIconSearch
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    self.tabBarItem.image = tabBarIcon;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Find Deals";
    self.isExplore = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

-(Boolean) getSearchMode
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"exploreMerchants"]) {
        // Grab the table view when it is embedded in the controller
        ExploreMerchantsTableViewController *tableViewController = [segue destinationViewController];
        tableViewController.selectedFilter = nil;
        tableViewController.proximity = DEFAULT_PROXIMITY;
        self.proximitySliderDelegate = tableViewController;
        self.merchantFilterDelegate = tableViewController;
        self.merchantTableViewController = tableViewController;
    }
}



@end
