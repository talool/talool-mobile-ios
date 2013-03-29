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
#import "talool-api-ios/ttMerchant.h"
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

- (void)viewDidAppear:(BOOL)animated
{
    // TODO this seems like a hacky way to get the deals for this table
    MerchantViewController *mvc = (MerchantViewController *) self.parentViewController;
    if (mvc != nil)
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        merchant = mvc.merchant;
        NSSet *ds = merchant.deals;
        if ([ds count]==0) {
            ds = [merchant getDeals:[CustomerHelper getLoggedInUser] context:appDelegate.managedObjectContext];
            [CustomerHelper save];
        }
        
        deals = [[NSMutableArray alloc] initWithArray:[ds allObjects]];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        deals = [[[NSArray alloc] initWithArray:[ds allObjects]] sortedArrayUsingDescriptors:sortDescriptors];
        
        [self.tableView reloadData];
    }
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
    [cell setDeal:[deals objectAtIndex:indexPath.row]];
	
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
