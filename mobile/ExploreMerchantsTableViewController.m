//
//  ExploreMerchantsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ExploreMerchantsTableViewController.h"
#import "MerchantViewController.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"

@interface ExploreMerchantsTableViewController ()

@end

@implementation ExploreMerchantsTableViewController


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
    // get merchants by proximity (manual override)
    int prox = self.proximity;
    if (self.proximity == 0 || self.proximity == MAX_PROXIMITY)
    {
        prox = INFINITE_PROXIMITY;
    }
    NSError *error;
    [[CustomerHelper getLoggedInUser] getMerchantsByProximity:prox
                                                    longitude:self.customerLocation.coordinate.longitude
                                                     latitude:self.customerLocation.coordinate.latitude
                                                      context:[CustomerHelper getContext]
                                                        error:&error];
    [super refreshMerchants];
}

@end
