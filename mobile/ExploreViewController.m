//
//  ExploreViewController.m
//  Talool
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ExploreViewController.h"
#import "MechantTableViewController.h"


@implementation ExploreViewController

@synthesize customer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.navigationItem.title = @"Explore";
    self.isExplore = YES;

}

-(void)viewDidAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
