//
//  MyDealsViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MyDealsViewController.h"
#import "MerchantDealViewController.h"
#import "AppDelegate.h"
#import "CustomerHelper.h"
#import "FontAwesomeKit.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "WelcomeViewController.h"
#import "MerchantSearchView.h"

@interface MyDealsViewController ()

@end

@implementation MyDealsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.loginViewController registerAuthDelegate:self];
    
    self.searchView = [[MerchantSearchView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)
                                                              isExplore:NO
                                                 merchantSearchDelegate:self];
    [self.view addSubview:self.searchView];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] == nil) {
        // The user isn't logged in, so kick them to the welcome view
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
    
    self.navigationItem.title = [[CustomerHelper getLoggedInUser] getFullName];
    
    // add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(settings:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    [settingsButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                                  forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"merchantDeals"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [self.merchants objectAtIndex:[indexPath row]];
        MerchantDealViewController *mvc = (MerchantDealViewController *)[segue destinationViewController];
        [mvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"welcome"])
    {
        WelcomeViewController *wvc = [segue destinationViewController];
        [wvc registerAuthDelegate:self];
        [wvc setHidesBottomBarWhenPushed:YES];
    }
}

#pragma mark -
#pragma mark - TaloolAuthenticationDelegate methods

- (void) customerLoggedIn:(id)sender
{
    [self.searchView fetchMerchants];
}

#pragma mark -
#pragma mark - TaloolGiftAcceptedDelegate methods

- (void) giftAccepted:(id)sender
{
    [self.searchView fetchMerchants];
}

@end
