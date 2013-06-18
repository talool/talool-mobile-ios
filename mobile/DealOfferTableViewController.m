//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
#import "DealOfferViewController.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealOfferCell.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"

@interface DealOfferTableViewController ()

@end

@implementation DealOfferTableViewController

@synthesize dealOffers, merchant;

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshDealOffers) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *err = nil;
    dealOffers = [ttDealOffer getDealOffers:customer context:[CustomerHelper getContext] error:&err];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [dealOffers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DealOfferCell";
    
    // Configure the cell...
    ttDealOffer *offer = [dealOffers objectAtIndex:indexPath.row];
    DealOfferCell *cell = (DealOfferCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setDealOffer:offer];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;

}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DealOfferViewController *dv = [self.storyboard instantiateViewControllerWithIdentifier:@"DealOfferView"];
    [dv setOffer:[dealOffers objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:dv animated:YES];
}

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDealOffer"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttDealOffer *offer = [dealOffers objectAtIndex:[indexPath row]];
        
        [[segue destinationViewController] setOffer:offer];
        
    }
}

@end
