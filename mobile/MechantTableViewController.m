//
//  ProfileTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MechantTableViewController.h"
#import "FavoriteMerchantCell.h"
#import "MerchantCell.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "CustomerHelper.h"
#import "AppDelegate.h"
#import "TaloolColor.h"

@interface MechantTableViewController ()

@end

@implementation MechantTableViewController
@synthesize merchants, sortDescriptors, searchMode, filterIndex, proximity;
@synthesize filteredMerchants;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[merchantSearchBar setShowsScopeBar:NO];
    //[merchantSearchBar sizeToFit];
    
    //if (!searchMode) {
        // Hide the search bar until user scrolls up
        // TODO remove the search bar if the user has only a few Merchants in the list
        //CGRect newBounds = self.tableView.bounds;
        //newBounds.origin.y = newBounds.origin.y + merchantSearchBar.bounds.size.height;
        //self.tableView.bounds = newBounds;
        ////NSArray *titles = [[NSArray alloc] initWithObjects:@"All", @"Favorites", nil];
        ////[merchantSearchBar setScopeButtonTitles:titles];
    //}
    
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    // TODO revisit to see when it's smart to refresh...
    [user refreshMerchants:[CustomerHelper getContext]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    merchants = [[[NSArray alloc] initWithArray:[user getMyMerchants]] sortedArrayUsingDescriptors:sortDescriptors];
    filteredMerchants = [NSMutableArray arrayWithCapacity:[merchants count]];
    filteredMerchants = [NSMutableArray arrayWithArray:merchants];
    
    [self.tableView reloadData];
    
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

#pragma mark -
#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    //if (tableView == self.searchDisplayController.searchResultsTableView) {
    //    return [filteredMerchants count];
    //} else {
        return [filteredMerchants count];
    //}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        // the search tableView is different than the default tableView,
        // so it didn't know about the defined cell.
        // pull the cell from the default tableView
        cell = (FavoriteMerchantCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
	
	// Configure the data for the cell.
    ttMerchant *merchant;
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    //if (tableView == self.searchDisplayController.searchResultsTableView) {
    //    merchant = [filteredMerchants objectAtIndex:indexPath.row];
    //} else {
        merchant = [filteredMerchants objectAtIndex:indexPath.row];
    //}
    [cell setMerchant:merchant];
	cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = ((MerchantCell *)cell).useDarkBackground ? self.darkBG : self.lightBG;
    [tableView setRowHeight:60.0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMerchant"]) {
        
        ttMerchant *merchant;
        
        // In order to manipulate the destination view controller, another check on which table (search or normal) is displayed is needed
        //if(sender == self.searchDisplayController.searchResultsTableView) {
        //    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        //    merchant = [filteredMerchants objectAtIndex:[indexPath row]];
        //}
        //else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            merchant = [filteredMerchants objectAtIndex:[indexPath row]];
        //}
        
        [[segue destinationViewController] setMerchant:merchant];
        
    }
}

- (void) refreshMerchants
{
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    [user refreshMerchants:[CustomerHelper getContext]];
    merchants = [[[NSArray alloc] initWithArray:[user getMyMerchants]] sortedArrayUsingDescriptors:sortDescriptors];
    filteredMerchants = [NSMutableArray arrayWithArray:merchants];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

/*
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [filteredMerchants removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    NSArray *tempArray = [merchants filteredArrayUsingPredicate:predicate];
    
    // TODO add scope support when we have categories to search
    if (![scope isEqualToString:@"All"] && NO) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
    
    filteredMerchants = [NSMutableArray arrayWithArray:tempArray];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
*/

-(void)setFilterIndex:(int)index
{
    self.filterIndex = index;
    [self filterMerchants];
}

- (void)proximityChanged:(float) valueInMiles sender:(id)sender
{
    proximity = [[[NSNumber alloc] initWithFloat:valueInMiles] intValue];
    [self filterMerchants];
}

- (void) filterMerchants
{
    // Remove all objects from the filtered search array
    [filteredMerchants removeAllObjects];
    
    NSArray *tempArray;
    
    // optional filter based on category or favorites
    if (filterIndex == 0)
    {
        // show all merchants
        tempArray = [NSMutableArray arrayWithArray:merchants];
    }
    else if (filterIndex == 1)
    {
        // only show favorites
        //NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"SELF.isFav contains[c] %@",1];
        //tempArray = [NSMutableArray arrayWithArray:[merchants filteredArrayUsingPredicate:categoryPredicate]];
    }
    else
    {
        // Filter based on category
        //NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",[self getCategoryName]];
        //tempArray = [NSMutableArray arrayWithArray:[merchants filteredArrayUsingPredicate:categoryPredicate]];
    }
    
    // filter the array based on proximity
    //NSPredicate *proximityPredicate = [NSPredicate predicateWithFormat:@"SELF.distance contains[c] %@",proximity];
    //tempArray = [tempArray filteredArrayUsingPredicate:proximityPredicate];
    
    filteredMerchants = [NSMutableArray arrayWithArray:tempArray];
    
    [self.tableView reloadData];
}

-(NSString *) getCategoryName
{
    // Turn the filterIndex into a category name to filter by
    return @"food";
}



@end
