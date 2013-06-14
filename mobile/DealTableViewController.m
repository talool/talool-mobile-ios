//
//  DealTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealTableViewController.h"
#import "DealRedemptionViewController.h"
#import "TaloolDealViewController.h"
#import "MerchantViewController.h"
#import "AppDelegate.h"
#import "CustomerHelper.h"
#import "TaloolColor.h"
#import "RewardCell.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttCustomer.h"

@interface DealTableViewController ()

@end

@implementation DealTableViewController
@synthesize deals, merchant, sortDescriptors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    ttCustomer *customer = [CustomerHelper getLoggedInUser];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSError *err = nil;
    deals = [customer getMyDealsForMerchant:merchant context:appDelegate.managedObjectContext error:&err];
    
    sortDescriptors = [NSArray arrayWithObjects:
                                //[NSSortDescriptor sortDescriptorWithKey:@"redeemed" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"invalidated" ascending:YES],
                                //[NSSortDescriptor sortDescriptorWithKey:@"expires" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"deal.title" ascending:YES],
                                nil];
    
    deals = [[[NSArray alloc] initWithArray:deals] sortedArrayUsingDescriptors:sortDescriptors];

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
    return [deals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RewardCell";
    
    RewardCell *cell = (RewardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the data for the cell.
    ttDealAcquire *deal = (ttDealAcquire *)[deals objectAtIndex:indexPath.row];
    [cell setDeal:deal];
    NSString *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    if ([deal hasBeenRedeemed])
    {
        date = [NSString stringWithFormat:@"Redeemed on %@", [dateFormatter stringFromDate:deal.redeemed]];
        
    }
    else if ([deal hasBeenShared])
    {
        if (deal.shared == nil)
        {
            date = @"Shared";
        }
        else
        {
            date = [NSString stringWithFormat:@"Shared on %@", [dateFormatter stringFromDate:deal.shared]];
        }
        
    }
    else if ([deal hasExpired])
    {
        date = [NSString stringWithFormat:@"Expired on %@", [dateFormatter stringFromDate:deal.deal.expires]];
    }
    if ([deal hasBeenRedeemed] || [deal hasBeenShared] || [deal hasExpired])
    {
        cell.contentView.alpha = 0.5;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.iconView.image = [UIImage imageNamed:@"Icon_tan.png"];
        
        NSDictionary* attributes = @{
                                     NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     };
        
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:deal.deal.title attributes:attributes];
        cell.nameLabel.text = nil;
        cell.nameLabel.attributedText = attrText;
    }
    else
    {
        if (deal.deal.expires ==  nil)
        {
            date = @"Never Expires";
        }
        else
        {
            date = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:deal.deal.expires]];
        }
        cell.contentView.alpha = 1.0;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.nameLabel.attributedText = nil;
        cell.nameLabel.text = deal.deal.title;
        cell.iconView.image = [UIImage imageNamed:@"Icon_teal.png"];
    }
    
    cell.dateLabel.text = date;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaloolDealViewController *dv = [self.storyboard instantiateViewControllerWithIdentifier:@"DealView"];
    [dv setDeal:[deals objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:dv animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDeal"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DealRedemptionViewController *controller = (DealRedemptionViewController *)[segue destinationViewController];
        [controller setDeal:[deals objectAtIndex:indexPath.row]];
    }
}


- (void) refreshDeals
{
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    NSError *error = nil;
    deals = [user refreshMyDealsForMerchant:merchant context:[CustomerHelper getContext] error:&error purge:true];
    deals = [[[NSArray alloc] initWithArray:deals] sortedArrayUsingDescriptors:sortDescriptors];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
