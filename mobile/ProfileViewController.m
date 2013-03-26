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
    self.tabBarController.navigationItem.title = [customer getFullName];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Logout"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(logout:)];
    self.tabBarController.navigationItem.rightBarButtonItem = logoutButton;
    
    self.tabBarController.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logout:(id)sender
{
    [self performSegueWithIdentifier:@"logoutUser" sender:self];
    
}



@end
