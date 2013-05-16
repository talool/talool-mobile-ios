//
//  LocationTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LocationTableViewController.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttCustomer.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "LocationCell.h"

@interface LocationTableViewController ()

@end

@implementation LocationTableViewController

@synthesize locations,merchant,sortDescriptors;

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshLocations) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    sortDescriptors = [NSArray arrayWithObjects:
                       //[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], // TODO distance
                       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                       nil];
    locations = [[[NSArray alloc] initWithArray:[merchant.locations allObjects]] sortedArrayUsingDescriptors:sortDescriptors];
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
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    LocationCell *cell = (LocationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell
    ttMerchantLocation *location = (ttMerchantLocation *)[locations objectAtIndex:indexPath.row];
    [cell setLocation:location];
    
    return cell;
}

- (void) refreshLocations
{
    // TODO do we really want to do this?
    //ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    //NSError *error = nil;
    //deals = [user refreshMyDealsForMerchant:merchant context:[CustomerHelper getContext] error:&error purge:true];
    //deals = [[[NSArray alloc] initWithArray:deals] sortedArrayUsingDescriptors:sortDescriptors];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
