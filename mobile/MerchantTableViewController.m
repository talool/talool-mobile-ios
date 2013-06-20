//
//  ProfileTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantTableViewController.h"
#import "MerchantViewController.h"
#import "AppDelegate.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttCustomer.h"

@interface MerchantTableViewController ()

@end


@implementation MerchantTableViewController

@synthesize newCustomerHandled, newGiftHandled;

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.loginViewController registerLogoutDelegate:self];
}


#pragma mark -
#pragma mark - Segue on merchant selection

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMerchant"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [self.filteredMerchants objectAtIndex:[indexPath row]];
        
        [[segue destinationViewController] setMerchant:merchant];
        
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
