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
#import "AcceptGiftViewController.h"
#import "FontAwesomeKit.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "SettingsTableViewController.h"

@interface MyDealsViewController ()

@end

@implementation MyDealsViewController

@synthesize newCustomerHandled, newGiftHandled;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavItem];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.settingsViewController registerLogoutDelegate:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavItem];
    
    if ([CustomerHelper getLoggedInUser] == nil) {
        // The user isn't logged in, so kick them to the welcome view
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self setNavItem];
    
    // search for gifts a little later, so we don't push the same view twice
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(checkForGifts:)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void) setNavItem
{
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

- (void) checkForGifts:(id)sender
{
    NSError *error;
    NSArray *gifts = [[CustomerHelper getLoggedInUser] getGifts:[CustomerHelper getContext] error:&error];
    // TODO if the user gets a bunch of gifts, we should show a table view
    if ([gifts count]>0)
    {
        // create the modal screen and show it
        AcceptGiftViewController *giftVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptGiftViewController"];
        giftVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        giftVC.gift = [gifts objectAtIndex:0];
        [self presentViewController:giftVC animated:YES completion:nil];
        
        [giftVC setGiftDelegate:self];
    }
}

- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"merchantDeals"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [self.filteredMerchants objectAtIndex:[indexPath row]];
        MerchantDealViewController *mvc = (MerchantDealViewController *)[segue destinationViewController];
        [mvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"welcome"])
    {
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    }
}

#pragma mark -
#pragma mark - Override Superclass Helpers

- (void) refreshMerchants
{
    [[CustomerHelper getLoggedInUser] refreshMerchants:[CustomerHelper getContext]];
    [super refreshMerchants];
}

- (void) merchantsUpdatedWithNewLocation
{
    [super merchantsUpdatedWithNewLocation];
    newCustomerHandled = YES;
    newGiftHandled = YES;
}

- (BOOL) hasLocationChanged
{
    BOOL b = [super hasLocationChanged];
    return (b || newCustomerHandled==NO || newGiftHandled==NO);
}

- (NSArray *) getAllMerchants
{
    return [[CustomerHelper getLoggedInUser] getMyMerchants];
}

#pragma mark -
#pragma mark - TaloolLogoutDelegate methods

- (void) customerLoggedOut:(id)sender
{
    newCustomerHandled = NO;
}

#pragma mark -
#pragma mark - TaloolGiftAcceptedDelegate methods

- (void) giftAccepted:(id)sender
{
    newGiftHandled = NO;
    [self refreshMerchants];
}

@end
