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
#import "WelcomeViewController.h"
#import "MyDealsViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

@synthesize customer, spinner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    customer = [CustomerHelper getLoggedInUser];
    nameLabel.text = [customer getFullName];
	self.navigationItem.title = @"Settings";
    
    spinner.hidesWhenStopped=YES;
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

- (void)logoutUser
{
    // CHECK FOR A FACEBOOK SESSION
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ttCustomer logoutUser:appDelegate.managedObjectContext];
}

- (void) delayedDeparture
{
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [self performSelector:@selector(delayedDeparture) withObject:nil afterDelay:3];
        return;
    }
    
    [self performSegueWithIdentifier:@"logout" sender:self];
    
    // remove the spinner
    [spinner stopAnimating];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"logout"])
    {
        WelcomeViewController *wvc = [segue destinationViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [wvc registerAuthDelegate:appDelegate.firstViewController];
        [wvc setHidesBottomBarWhenPushed:YES];
    }
}

- (IBAction)logout:(id)sender
{
    // add a spinner
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    [self logoutUser];
    
    // make sure the FB session is closed before we split
    if (FBSession.activeSession.isOpen)
    {
        [self performSelector:@selector(delayedDeparture) withObject:nil afterDelay:3];
    }
    else
    {
        [self delayedDeparture];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
