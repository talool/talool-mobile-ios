//
//  MerchantDealOfferViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantDealOfferViewController.h"
#import "DealOfferViewController.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealOfferCell.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"

@interface MerchantDealOfferViewController ()

@end

@implementation MerchantDealOfferViewController

@synthesize tableView, refreshControl, dealOffers, sortDescriptors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshDealOffers) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *err = nil;
    dealOffers = [ttDealOffer getDealOffers:customer context:[CustomerHelper getContext] error:&err];
    
    [self.tableView reloadData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue identifier] isEqualToString:@"showDealOffer"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttDealOffer *offer = [dealOffers objectAtIndex:[indexPath row]];
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
        [[segue destinationViewController] setOffer:offer];
        
    }
}


#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dealOffers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DealOfferCell";
    
    // Configure the cell...
    ttDealOffer *offer = [dealOffers objectAtIndex:indexPath.row];
    DealOfferCell *cell = (DealOfferCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setDealOffer:offer];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UIRefreshControl

- (void) refreshDealOffers
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *err = nil;
    dealOffers = [ttDealOffer getDealOffers:customer context:[CustomerHelper getContext] error:&err];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end