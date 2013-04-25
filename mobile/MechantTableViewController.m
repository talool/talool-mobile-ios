//
//  ProfileTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MechantTableViewController.h"
#import "talool-api-ios/MerchantController.h"
#import "FavoriteMerchantCell.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "CustomerHelper.h"
#import "AppDelegate.h"
#import "TaloolColor.h"

@interface MechantTableViewController ()

@end

@implementation MechantTableViewController
@synthesize merchants, sortDescriptors;

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    merchants = [[[NSArray alloc] initWithArray:[user getMyMerchants]] sortedArrayUsingDescriptors:sortDescriptors];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshMerchants) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [merchants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
    //cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	// Configure the data for the cell.
    [cell setMerchant:[merchants objectAtIndex:indexPath.row]];
	cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = ((MerchantCell *)cell).useDarkBackground ? self.darkBG : self.lightBG;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMerchant"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setMerchant:[merchants objectAtIndex:indexPath.row]];
        
    }
}

- (void) refreshMerchants
{
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    [user refreshMerchants:[CustomerHelper getContext]];
    merchants = [[[NSArray alloc] initWithArray:[user getMyMerchants]] sortedArrayUsingDescriptors:sortDescriptors];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}



@end
