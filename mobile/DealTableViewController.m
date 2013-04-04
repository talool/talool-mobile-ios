//
//  DealTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealTableViewController.h"
#import "DataViewController.h"
#import "MerchantViewController.h"
#import "AppDelegate.h"
#import "CustomerHelper.h"

@interface DealTableViewController ()

@end

@implementation DealTableViewController
@synthesize deals, merchant;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{

    // Watch out.  This assumes the top controller is a MerchantViewController.
    MerchantViewController *mvc = (MerchantViewController *) self.navigationController.topViewController;
    merchant = mvc.merchant;
    
    NSSet *ds = merchant.deals;
    if ([ds count]==0) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        ds = [merchant getDeals:[CustomerHelper getLoggedInUser] context:appDelegate.managedObjectContext];
        [CustomerHelper save];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                [NSSortDescriptor sortDescriptorWithKey:@"redeemed" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],
                                nil];
    
    deals = [[[NSArray alloc] initWithArray:[ds allObjects]] sortedArrayUsingDescriptors:sortDescriptors];

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
    ttDeal *deal = (ttDeal *)[deals objectAtIndex:indexPath.row];
    [cell setDeal:deal];
    
    if ([deal.redeemed intValue] == 1) {
        cell.contentView.alpha = 0.5;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        // Tan: [UIColor colorWithRed:218.0/255.0 green:215.0/255.0 blue:197.0/255.0 alpha:1.0];
    } else {
        cell.contentView.alpha = 1.0;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        // Teal: [UIColor colorWithRed:25.0/255.0 green:188.0/255.0 blue:185.0/255.0 alpha:1.0];
    }
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDeal"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DataViewController *dvController = (DataViewController *)[segue destinationViewController];
        [dvController setCoupon:[deals objectAtIndex:indexPath.row]];
        dvController.title = merchant.name;
        
    }
}

@end
