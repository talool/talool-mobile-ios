//
//  ActivityViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityViewController.h"
#import "AcceptGiftViewController.h"
#import "CustomerHelper.h"
#import "ActivityCell.h"
#import "ActivityFilterView.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttActivity.h"
#import "talool-api-ios/ttActivityLink.h"
#import "TaloolMobileWebViewController.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController

@synthesize tableView, refreshControl, filterView, activities;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [TaloolColor gray_3];
    [refreshControl addTarget:self action:@selector(refreshActivities) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.filterView = [[ActivityFilterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)
                                         activityStreamDelegate:self];
    [self.view addSubview:self.filterView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.filterView fetchActivities];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openGift"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttActivity *activity = [self.activities objectAtIndex:[indexPath row]];
        NSString *giftId = activity.link.elementId;
        
        // gifts were loaded when the activities where loaded, so we should
        // be able to get the gift from the context
        NSError *error;
        ttGift *gift = [ttGift getGiftById:giftId customer:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
        //NSLog(@"show Gift: %@",gift.deal.title);
        AcceptGiftViewController *agvc = (AcceptGiftViewController *)[segue destinationViewController];
        [agvc setGift:gift];
        
        // TODO we may have to register multiple deletages.  My Deals should reload too.
        // * could chain delegates together
        [agvc setGiftDelegate:self];
    }
    else if ([[segue identifier] isEqualToString:@"WelcomeActivity"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttActivity *activity = [self.activities objectAtIndex:[indexPath row]];
        //NSLog(@"mobile web welcome url: %@",activity.link.elementId);
        [[segue destinationViewController] setMobileWebUrl:activity.link.elementId];
        [[segue destinationViewController] setViewTitle:@"Welcome"];
    }
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [activities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.activities objectAtIndex:[indexPath row]];
    
    NSString *CellIdentifier;
    if ([activity isFacebookReceiveGiftEvent] || [activity isEmailReceiveGiftEvent])
    {
        if ([activity isClosed])
        {
            CellIdentifier = @"ActivityCell";
        }
        else
        {
            CellIdentifier = @"GiftCell";
        }
    }
    else if ([activity isWelcomeEvent])
    {
        CellIdentifier = @"WelcomeCell";
    }
    else
    {
        CellIdentifier = @"ActivityCell";
    }
    
    ActivityCell *cell = (ActivityCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setActivity:activity];
    
    return cell;
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshActivities
{
    // Override in subclass to hit the service
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [filterView fetchActivities];
    [self.refreshControl endRefreshing];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -60 && ![self.refreshControl isRefreshing]) {
        [self.refreshControl beginRefreshing];
        [self refreshActivities];
    }
}

#pragma mark -
#pragma mark - ActivityStreamDelegate methods

- (void)activitySetChanged:(NSArray *)newActivies sender:(id)sender
{
    activities = newActivies;
    [self.tableView reloadData];
}

- (void) giftSetChanged:(NSArray *)gifts sender:(id)sender
{
    NSString *badge;
    if ([gifts count] > 0)
    {
        badge = [NSString stringWithFormat:@"%d",[gifts count]];
    }
    [[self navigationController] tabBarItem].badgeValue = badge;
}

#pragma mark -
#pragma mark - TaloolGiftAcceptedDelegate methods

- (void)giftAccepted:(ttDealAcquire *)deal sender:(id)sender
{
    [filterView fetchActivities];
}

@end
