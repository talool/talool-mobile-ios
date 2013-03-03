//
//  TaloolTabBarController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolTabBarController.h"
#import "MasterNavigationController.h"

@interface TaloolTabBarController ()

@end

@implementation TaloolTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self checkForRegistration];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onLogout:(id) sender
{
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
    [mnc logout];
    [self checkForRegistration];
}

- (IBAction)loginAction:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"loginUser"]) {
        //not sure what I might do here...
    }
}

- (void) checkForRegistration
{
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
    if ([mnc getLoggedInUser] == nil) {
        [self performSegueWithIdentifier:@"registerUser" sender:self.navigationController];
    }
}

@end
