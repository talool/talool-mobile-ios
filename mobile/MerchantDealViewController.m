//
//  MerchantDealViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantDealViewController.h"
#import "DealViewController.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealAcquireCell.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttCustomer.h"


@interface MerchantDealViewController ()

@end

@implementation MerchantDealViewController

@synthesize tableView, refreshControl, deals, sortDescriptors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *err = nil;
    deals = [[CustomerHelper getLoggedInUser] getMyDealsForMerchant:merchant context:[CustomerHelper getContext] error:&err];
    
    sortDescriptors = [NSArray arrayWithObjects:
                       //[NSSortDescriptor sortDescriptorWithKey:@"redeemed" ascending:YES],
                       [NSSortDescriptor sortDescriptorWithKey:@"invalidated" ascending:YES],
                       //[NSSortDescriptor sortDescriptorWithKey:@"expires" ascending:YES],
                       [NSSortDescriptor sortDescriptorWithKey:@"deal.title" ascending:YES],
                       nil];
    
    deals = [[[NSArray alloc] initWithArray:deals] sortedArrayUsingDescriptors:sortDescriptors];
    
    [self.tableView reloadData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue identifier] isEqualToString:@"showDeal"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttDealAcquire *deal = [deals objectAtIndex:[indexPath row]];
        DealViewController *tdvc = [segue destinationViewController];
        [tdvc setHidesBottomBarWhenPushed:YES];
        [tdvc setDeal:deal];
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
    return [deals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RewardCell";
    
    DealAcquireCell *cell = (DealAcquireCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
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

#pragma mark - UIRefreshControl

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
