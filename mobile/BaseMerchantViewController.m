//
//  BaseMerchantTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseMerchantViewController.h"
#import "FavoriteMerchantCell.h"
#import "MerchantCell.h"
#import "MerchantFilterControl.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "TaloolColor.h"
#import "MerchantSearchView.h"

@interface BaseMerchantViewController ()

@end

@implementation BaseMerchantViewController

@synthesize merchants, tableView, refreshControl, searchView;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshMerchants) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
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
    return [merchants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the data for the cell.
    ttMerchant *merchant = [merchants objectAtIndex:indexPath.row];
    //[cell setMerchant:merchant];
    ttCategory *cat = (ttCategory *)merchant.category;
    ttMerchantLocation *loc = [merchant getClosestLocation];
    
    CategoryHelper *helper = [[CategoryHelper alloc] init];
    [cell setIcon:[helper getIcon:[cat.categoryId intValue]]];
    [cell setName:merchant.name];
    if ([loc getDistanceInMiles] == nil || [[loc getDistanceInMiles] intValue]==0)
    {
        [cell setDistance:@"  "];
    }
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@"###0.##"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *miles = [formatter stringFromNumber:[loc getDistanceInMiles]];
        [cell setDistance: [NSString stringWithFormat:@"%@ miles",miles] ];
    }
    [cell setAddress:[merchant getLocationLabel]];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshMerchants
{
    // Override in subclass to hit the service
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [searchView fetchMerchants];
    [self.refreshControl endRefreshing];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -60 && ![self.refreshControl isRefreshing]) {
        [self.refreshControl beginRefreshing];
        [self refreshMerchants];
    }
}

#pragma mark -
#pragma mark - MerchantSearchDelegate methods

- (void)merchantSetChanged:(NSArray *)newMerchants sender:(id)sender
{
    merchants = newMerchants;
    [self.tableView reloadData];
}



@end
