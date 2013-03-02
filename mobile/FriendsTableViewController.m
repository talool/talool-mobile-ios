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
    //[self.customerController loadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Friends";
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFriend"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setCustomer:[customerController objectInCustomersAtIndex:indexPath.row]];
        
    }
}


@end
