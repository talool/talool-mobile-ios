//
//  SetttingsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SetttingsTableViewController.h"
#import "CustomerHelper.h"

@interface SetttingsTableViewController ()

@end

@implementation SetttingsTableViewController

@synthesize customer;


- (void)viewDidLoad
{
    [super viewDidLoad];
    customer = [CustomerHelper getLoggedInUser];
    nameLabel.text = [customer getFullName];
	self.navigationItem.title = @"Settings";
}


- (IBAction)logout:(id)sender
{
    [self performSegueWithIdentifier:@"logoutUser" sender:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
