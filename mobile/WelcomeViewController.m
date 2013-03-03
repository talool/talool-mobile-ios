//
//  WelcomeViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "WelcomeViewController.h"
#import "MasterNavigationController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
	if ([mnc getLoggedInUser] != nil) {
        // TODO need to save state of the UI correctly.  This is a temporary hack.
        [self performSegueWithIdentifier:@"loginUser" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutAction:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"logoutUser"]) {
        MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
        [mnc logout];
    }
}

@end
