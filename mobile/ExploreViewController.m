//
//  ExploreViewController.m
//  Talool
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ExploreViewController.h"
#import "MechantTableViewController.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.navigationItem.title = @"Explore";

}

-(void)viewDidAppear:(BOOL)animated
{
    UIImage *gears = [UIImage imageNamed:@"gear.png"];
    UIBarButtonItem *filtersButton = [[UIBarButtonItem alloc] initWithImage:gears style:UIBarButtonItemStyleBordered target:self action:@selector(filters:)];
    self.tabBarController.navigationItem.rightBarButtonItem = filtersButton;
    
    self.tabBarController.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)filters:(id)sender
{
    [self performSegueWithIdentifier:@"searchFilters" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"exploreMerchants"]) {
        MechantTableViewController *mtvc = [segue destinationViewController];
        [mtvc setSearchMode:YES];
    }
}

@end
