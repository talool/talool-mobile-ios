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
#import "MerchantSearchView.h"


@implementation FindDealsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchView = [[MerchantSearchView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)
                                                      isExplore:YES
                                         merchantSearchDelegate:self];
    [self.view addSubview:self.searchView];
    
    // Load any merchants we have in the context
    if ([merchants count]==0)
    {
        NSArray *unsortedMerchants = [ttMerchant getMerchantsInContext:[CustomerHelper getContext]];
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        merchants = [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"merchantDealOffers"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [self.merchants objectAtIndex:[indexPath row]];
        MerchantDealOfferViewController *mvc = (MerchantDealOfferViewController *)[segue destinationViewController];
        [mvc setMerchant:merchant];
    }
}


@end
