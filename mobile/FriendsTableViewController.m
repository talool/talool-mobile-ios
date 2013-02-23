//
//  FriendsTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "Friend.h"
#import "CustomerController.h"
#import "FriendCell.h"

@interface FriendsTableViewController ()
@property (nonatomic, retain) CustomerController *customerController;
@end

@implementation FriendsTableViewController
@synthesize customerController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The FriendController will fetch the data for this view
    self.customerController = [[CustomerController alloc] init];
    [self.customerController loadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	[super viewDidLoad];
	
    self.customerController = nil;
}


// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return customerController.countOfCustomers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomerCell";
    
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Display dark and light background in alternate rows
    cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	// Configure the data for the cell.
    [cell setCustomer:[self.customerController objectInCustomersAtIndex:indexPath.row]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((FriendCell *)cell).useDarkBackground ? self.darkBG : self.lightBG;
}

// Cell touch handler that pushes the recipe detail view onto the navigation controller stack
- (void)showFriend:(Customer *)friend animated:(BOOL)animated {
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

// Call the cell touch handler and pass in the Friend associated with the argument section/row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Customer *friend = [customerController objectInCustomersAtIndex:indexPath.row];
    [self showFriend:friend animated:YES];
}

@end
