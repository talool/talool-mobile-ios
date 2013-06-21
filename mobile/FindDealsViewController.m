//
//  FindDealsViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FindDealsViewController.h"
#import "MerchantDealOfferViewController.h"
#import "FavoriteMerchantCell.h"
#import "MerchantCell.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"
#import "MerchantFilterControl.h"


@interface FindDealsViewController ()

@end

@implementation FindDealsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.filterControl removeSegmentAtIndex:1 animated:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isExplore = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"merchantDealOffers"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [self.filteredMerchants objectAtIndex:[indexPath row]];
        MerchantDealOfferViewController *mvc = (MerchantDealOfferViewController *)[segue destinationViewController];
        [mvc setMerchant:merchant];
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
