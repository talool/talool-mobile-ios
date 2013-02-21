//
//  ExploreTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//


#import "ExploreTableViewController.h"

#import "Merchant.h"
#import "MerchantController.h"
#import "FavoriteMerchantCell.h"

/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]


@interface ExploreTableViewController ()
@property (nonatomic, retain) MerchantController *merchantController;
@end

@implementation ExploreTableViewController
@synthesize merchantController, tmpCell, cellNib;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the table view.
    self.tableView.rowHeight = 73.0;
    self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // The merchantController will fetch the data for this view
    self.merchantController = [[MerchantController alloc] init];
    [self.merchantController loadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    cell.backgroundColor = ((MerchantCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
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





