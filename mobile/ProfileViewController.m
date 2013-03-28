//
//  FirstViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileViewController.h"
#import "CustomerHelper.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize customer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    customer = [CustomerHelper getLoggedInUser];
    nameLabel.text = customer.lastName;
}

-(void)viewDidAppear:(BOOL)animated
{
    customer = [CustomerHelper getLoggedInUser];
    self.tabBarController.navigationItem.title = [customer getFullName];
    
    UIImage *gears = [UIImage imageNamed:@"gear.png"];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:gears style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];
    self.tabBarController.navigationItem.rightBarButtonItem = settingsButton;
    
    self.tabBarController.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"userSettings" sender:self];
}



@end
