//
//  ProfileTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileTableViewController.h"

#import "Merchant.h"
#import "MerchantController.h"
#import "FavoriteMerchantCell.h"

@interface ProfileTableViewController ()
@property (nonatomic, retain) MerchantController *merchantController;
@end

@implementation ProfileTableViewController
@synthesize merchantController, tmpCell, cellNib;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The merchantController will fetch the data for this view
    self.merchantController = [[MerchantController alloc] init];
    [self.merchantController loadData];
    
	self.cellNib = [UINib nibWithNibName:@"FavoriteMerchantCell" bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	[super viewDidLoad];
	
	self.tmpCell = nil;
	self.cellNib = nil;
    self.merchantController = nil;
}


// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return merchantController.countOfMerchants;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    MerchantCell *cell = (MerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {
        [self.cellNib instantiateWithOwner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
    }
    
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
    cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	// Configure the data for the cell.
    [cell setMerchant:[self.merchantController objectInMerchantsAtIndex:indexPath.row]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((MerchantCell *)cell).useDarkBackground ? self.darkBG : self.lightBG;
}

// Cell touch handler that pushes the recipe detail view onto the navigation controller stack
- (void)showMerchant:(Merchant *)merchant animated:(BOOL)animated {
    //RecipeDetailViewController *detailViewController = [[RecipeDetailViewController alloc] initWithRecipe:recipe];
    //[self.navigationController pushViewController:detailViewController animated:animated];
    //[detailViewController release];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
}

// Call the cell touch handler and pass in the merchant associated with the argument section/row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Merchant *merchant = [merchantController objectInMerchantsAtIndex:indexPath.row];
    [self showMerchant:merchant animated:YES];
}

@end
