//
//  SetttingsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "CustomerHelper.h"
#import "AppDelegate.h"
#import "FacebookSDK/FacebookSDK.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

@synthesize customer;


- (void)viewDidLoad
{
    [super viewDidLoad];
    customer = [CustomerHelper getLoggedInUser];
    nameLabel.text = [customer getFullName];
	self.navigationItem.title = @"Settings";
}

- (void)logoutUser
{
    // CHECK FOR A FACEBOOK SESSION
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ttCustomer logoutUser:appDelegate.managedObjectContext];
    [logoutDelegate customerLoggedOut:self];
}

- (IBAction)logout:(id)sender
{
    [self logoutUser];
    [self performSegueWithIdentifier:@"logout" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerLogoutDelegate:(id <TaloolLogoutDelegate>)delegate
{
    logoutDelegate = delegate;
}

@end
