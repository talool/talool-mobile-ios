//
//  ActivityViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityViewController.h"
#import "AcceptGiftViewController.h"
#import "AppDelegate.h"
#import "CustomerHelper.h"
#import "TextureHelper.h"
#import "ActivityCell.h"
#import "ActivityFilterView.h"
#import "ActivityStreamHelper.h"
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

@synthesize activities;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activities = [[CustomerHelper getLoggedInUser] fetchActivities:[CustomerHelper getContext]];
    
    [self.refreshControl addTarget:self action:@selector(refreshActivities) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Activities"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MarkerFelt-Thin" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor gray_2] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    // Creating view for extending background color
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView* bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [TaloolColor gray_5];
    UIImageView *texture = [[UIImageView alloc] initWithImage:[TextureHelper getTextureWithColor:[TaloolColor gray_4] size:frame.size]];
    [texture setAlpha:0.2];
    [bgView addSubview:texture];
    
    // Adding the view below the refresh control
    [self.tableView insertSubview:bgView atIndex:0];
    
    self.filterView = [[ActivityFilterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)
                                         activityStreamDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    activities = appDelegate.activityHelper.activities;
    [self refreshActivities];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.activities objectAtIndex:[indexPath row]];
    if ([activity isWelcomeEvent] || [activity isTaloolReachEvent] || [activity isMerchantReachEvent])
    {
        [activity actionTaken:[CustomerHelper getLoggedInUser]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.filterView;
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
    [self.filterView fetchActivities];
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - ActivityStreamDelegate methods

- (void)activitySetChanged:(NSArray *)newActivies sender:(id)sender
{
    activities = newActivies;
    [self.tableView reloadData];
}

- (void)openActivityCountChanged:(int)count sender:(id)sender
{
    NSString *badge;
    if (count > 0)
    {
        badge = [NSString stringWithFormat:@"%d",count];
    }
    [[self navigationController] tabBarItem].badgeValue = badge;
}

#pragma mark -
#pragma mark - TaloolGiftAcceptedDelegate methods

- (void)giftAccepted:(ttDealAcquire *)deal sender:(id)sender
{
    [self.filterView fetchActivities];
}

@end
