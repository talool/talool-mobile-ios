//
//  ProfileTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "MasterNavigationController.h"
#import "talool-service.h"
#import "MerchantController.h"
#import "FavoriteMerchantCell.h"
#import "ttCustomer.h"

@interface ProfileTableViewController ()
@property (nonatomic, retain) MerchantController *merchantController;
@end

@implementation ProfileTableViewController
@synthesize merchantController;

- (void)viewDidAppear:(BOOL)animated
{
    // Set the nav title to the user's first name
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
    self.tabBarController.navigationItem.title = [[mnc getLoggedInUser] getFullName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The merchantController will fetch the data for this view
    self.merchantController = [[MerchantController alloc] init];
    //[self.merchantController loadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	[super viewDidLoad];
	
    self.merchantController = nil;
}


// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return merchantController.countOfMerchants;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setMerchant:[merchantController objectInMerchantsAtIndex:indexPath.row]];
        
    }
}


@end
