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

@synthesize helpButton;

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
    
    // load any merchants connected to this customer from the context
    if ([merchants count]==0)
    {
        NSArray *unsortedMerchants = [[CustomerHelper getLoggedInUser] getMyMerchants];
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        merchants = [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    [self askForHelp];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeHelp];
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
#pragma mark - Help Overlay Methods

- (void) askForHelp
{
    // if merchants are still 0, we should show the user some help
    if ([merchants count]==0)
    {
        helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpBuyDealsWithCode.png"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(closeHelp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:helpButton];
    }
    else
    {
        // check if there are deals
        if (![[CustomerHelper getLoggedInUser] hasDeals:[CustomerHelper getContext]])
        {
            helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpBuyDeals.png"] forState:UIControlStateNormal];
            [helpButton addTarget:self action:@selector(closeHelp) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:helpButton];
        }
    }
}

- (void)closeHelp
{
    if (helpButton)
    {
        [helpButton removeFromSuperview];
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

- (void) giftAccepted:(ttDealAcquire *)deal sender:(id)sender
{
    // TODO add the merchant and the deal to the customer w/o pulling everything
    [self.searchView fetchMerchants];
}

@end
