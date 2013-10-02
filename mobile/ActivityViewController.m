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
#import "ActivityCell.h"
#import "HeaderPromptCell.h"
#import "FooterPromptCell.h"
#import "ActivityFilterView.h"
#import "ActivityStreamHelper.h"
#import "ActivityFilterControl.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttActivity.h"
#import "talool-api-ios/ttActivityLink.h"
#import "TaloolMobileWebViewController.h"
#import "FontAwesomeKit.h"

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
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    self.filterView = [[ActivityFilterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)
                                         activityStreamDelegate:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    activities = appDelegate.activityHelper.activities;
    [self updateTable];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openGift"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttActivity *activity = [self.activities objectAtIndex:([indexPath row]-1)];
        NSString *giftId = activity.link.elementId;
        
        // gifts were loaded when the activities where loaded, so we should
        // be able to get the gift from the context
        NSError *error;
        ttGift *gift = [ttGift getGiftById:giftId customer:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];

        AcceptGiftViewController *agvc = (AcceptGiftViewController *)[segue destinationViewController];
        [agvc setGift:gift];
        [agvc setGiftDelegate:self];
    }
    else if ([[segue identifier] isEqualToString:@"WelcomeActivity"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttActivity *activity = [self.activities objectAtIndex:([indexPath row]-1)];

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
    return [activities count]+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        return [self getHeaderCell:indexPath];
    }
    else if (indexPath.row == [activities count]+1)
    {
        NSString *CellIdentifier = @"FooterCell";
        FooterPromptCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setSimpleAttributedMessage:@"Need Deals? Find Deals!" icon:FAKIconArrowDown icon:FAKIconArrowDown];
        return cell;
    }
    else
    {
        return [self getActivityCell:indexPath];
    }
}

- (UITableViewCell *)getHeaderCell:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TileTop";
    HeaderPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([activities count]==0) {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60Last.png"];
    }
    else
    {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60.png"];
    }
    NSString *prompt;
    switch (self.filterView.filterControl.selectedSegmentIndex) {
        case 1:
            prompt = @"Gifts sent and received";
            break;
            
        case 2:
            prompt = @"Purchases and redeemed deals";
            break;
            
        case 3:
            prompt = @"Your friends' activity";
            break;
            
        case 4:
            prompt = @"Messages from merchants and Talool";
            break;
            
        default:
            prompt = @"All your activities on Talool";
            break;
    }

    [cell setMessage:prompt];
 
    return cell;
}

- (UITableViewCell *)getActivityCell:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.activities objectAtIndex:([indexPath row]-1)];
    
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
    
    if (indexPath.row == [activities count]) {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell90Last.png"];
    }
    else
    {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell90.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row==0 || indexPath.row == [activities count]+1)?60.0:90.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.activities objectAtIndex:([indexPath row]-1)];
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
