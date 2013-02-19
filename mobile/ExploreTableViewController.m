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

#import "MerchantCell.h"


// Define one of the following macros to 1 to control which type of cell will be used.
#define USE_INDIVIDUAL_SUBVIEWS_CELL    1	// use a xib file defining the cell
#define USE_COMPOSITE_SUBVIEW_CELL      0	// use a single view to draw all the content
#define USE_HYBRID_CELL                 0	// use a single view to draw most of the content + separate label to render the rest of the content


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
@synthesize merchantController, tmpCell, data, cellNib;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the table view.
    self.tableView.rowHeight = 73.0;
    self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	// Load the data.
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"MerchantData" ofType:@"plist"];
    self.data = [NSArray arrayWithContentsOfFile:dataPath];
    
    self.merchantController = [[MerchantController alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // create our UINib instance which will later help us load and instanciate the
	// UITableViewCells's UI via a xib file.
	//
	// Note:
	// The UINib classe provides better performance in situations where you want to create multiple
	// copies of a nib file’s contents. The normal nib-loading process involves reading the nib file
	// from disk and then instantiating the objects it contains. However, with the UINib class, the
	// nib file is read from disk once and the contents are stored in memory.
	// Because they are in memory, creating successive sets of objects takes less time because it
	// does not require accessing the disk.
	//
	self.cellNib = [UINib nibWithNibName:@"MerchantCell" bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	[super viewDidLoad];
	
	self.data = nil;
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
    static NSString *CellIdentifier = @"ApplicationCell";
    
    ApplicationCell *cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {
//#if USE_INDIVIDUAL_SUBVIEWS_CELL
        [self.cellNib instantiateWithOwner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
/*
#elif USE_COMPOSITE_SUBVIEW_CELL
        cell = [[[CompositeSubviewBasedApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:CellIdentifier] autorelease];
		
#elif USE_HYBRID_CELL
        cell = [[[HybridSubviewBasedApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CellIdentifier] autorelease];
#endif
 */
    }
    
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
    cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	// Configure the data for the cell.
    NSDictionary *dataItem = [data objectAtIndex:indexPath.row];
    cell.icon = [UIImage imageNamed:[dataItem objectForKey:@"Icon"]];
    cell.publisher = [dataItem objectForKey:@"Publisher"];
    cell.name = [dataItem objectForKey:@"Name"];
    //cell.numRatings = [[dataItem objectForKey:@"NumRatings"] intValue];
    //cell.rating = [[dataItem objectForKey:@"Rating"] floatValue];
    cell.price = [dataItem objectForKey:@"Price"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
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





