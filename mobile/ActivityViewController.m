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
#import "ActivityFilterControl.h"
#import "TaloolColor.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttActivity.h"
#import "Talool-API/ttActivityLink.h"
#import "TaloolMobileWebViewController.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import <OperationQueueManager.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface ActivityViewController ()
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property BOOL resetAfterLogin;
@end

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.refreshControl addTarget:self action:@selector(refreshActivities) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Activities"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TrebuchetMS" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    self.filterView = [[ActivityFilterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0) activityFilterDelegate:self];
    
    _sortDescriptors = [NSArray arrayWithObjects:
                        [NSSortDescriptor sortDescriptorWithKey:@"activityDate" ascending:NO],
                        [NSSortDescriptor sortDescriptorWithKey:@"activityId" ascending:NO],
                        nil];
    
    [self resetFetchedResultsController:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAcceptedGift:)
                                                 name:CUSTOMER_ACCEPTED_GIFT
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogin:)
                                                 name:LOGIN_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleActivity:)
                                                 name:ACTIVITY_NOTIFICATION
                                               object:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_resetAfterLogin)
    {
        [self forcedClearOfTableView];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Activity Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) updateBadge:(NSNumber *)count
{
    NSString *badge;
    if ([count intValue] > 0)
    {
        badge = [NSString stringWithFormat:@"%@",count];
    }
    [[self navigationController] tabBarItem].badgeValue = badge;
}

- (void) handleUserLogin:(NSNotification *)message
{
    _resetAfterLogin = YES;
    [self.filterView.filterControl setSelectedSegmentIndex:0];
}

- (void) handleActivity:(NSNotification *)message
{
    [self resetFetchedResultsController:NO];
}

- (void) handleAcceptedGift:(NSNotification *)message
{
    // refresh the activity for this gift so the cell updates
    NSString *giftId = [message.userInfo objectForKey:DELEGATE_RESPONSE_OBJECT_ID];
    [ttActivity refreshActivityForGiftId:giftId context:[CustomerHelper getContext]];
    
    [[OperationQueueManager sharedInstance] startActivityOperation:self completionHander:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openGift"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttActivity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *giftId = activity.link.elementId;

        AcceptGiftViewController *agvc = (AcceptGiftViewController *)[segue destinationViewController];
        [agvc setGiftId:giftId];
    }
    else if ([[segue identifier] isEqualToString:@"WelcomeActivity"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttActivity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];

        [[segue destinationViewController] setMobileWebUrl:activity.link.elementId];
        [[segue destinationViewController] setViewTitle:@"Welcome"];
    }
}

/*
    Multi-User Edge Case:
    Create an emptyset for the fetched result controller to clear the list of any old data
    that may be left from a previous user.
 */
- (void) forcedClearOfTableView
{
    _resetAfterLogin = NO;
    NSPredicate *purgePredicate = [NSPredicate predicateWithFormat:@"SELF.title == nil"];
    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:purgePredicate];
    [self resetFetchedResultsController:NO];
    [self resetFetchedResultsController:YES];
}


#pragma mark -
#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    [self.tableView reloadData];
    
    NSPredicate *predicate = [self.filterView.filterControl getPredicateAtSelectedIndex];
    
    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return _fetchedResultsController;
    
}

- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACTIVITY_ENTITY_NAME
                                              inManagedObjectContext:[CustomerHelper getContext]];
    [fetchRequest setEntity:entity];
    
    if (predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    
    [fetchRequest setSortDescriptors:_sortDescriptors];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[CustomerHelper getContext]
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    theFetchedResultsController.delegate = self;
    
    return theFetchedResultsController;
}

- (void) resetFetchedResultsController:(BOOL)hard
{
    [[CustomerHelper getContext] processPendingChanges];
    if (hard)
    {
        _fetchedResultsController = nil;
    }
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.tableView reloadData];
    
}

- (int)activityCount
{
    return [_fetchedResultsController.fetchedObjects count];
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self activityCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getActivityCell:indexPath];
}

- (UITableViewCell *)getHeaderCell:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TileTop";
    HeaderPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    
    NSString *identifier = [self getCellIdentifier:indexPath];
    ActivityCell *cell = (ActivityCell *)[self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self configureCell:cell path:indexPath];
    
    return cell;
}

- (NSString *) getCellIdentifier:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
    return CellIdentifier;
}

- (void) configureCell:(ActivityCell *)cell path:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setActivity:activity];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttActivity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([activity isWelcomeEvent] || [activity isTaloolReachEvent] || [activity isMerchantReachEvent])
    {
        [[OperationQueueManager sharedInstance] startCloseActivityOperation:activity.activityId delegate:self];
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
    [[OperationQueueManager sharedInstance] startActivityOperation:self completionHander:nil];
}

- (void) updateTable
{
    [self.refreshControl endRefreshing];
}


#pragma mark -
#pragma mark - ActivityFilterDelegate methods

- (void)filterChanged:(NSPredicate *)predicate sender:(id)sender
{
    [self resetFetchedResultsController:YES];
}


#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void)activityOperationComplete:(NSDictionary *)response
{
    
    NSString *activityId = [response objectForKey:DELEGATE_RESPONSE_OBJECT_ID];
    if (activityId)
    {
        NSManagedObjectContext *context = [CustomerHelper getContext];
        ttActivity *act = [ttActivity fetchById:activityId context:context];
        [context refreshObject:act mergeChanges:YES];
    }
    
    NSNumber *openCount = [response objectForKey:DELEGATE_RESPONSE_COUNT];
    if (openCount)
    {
        [self updateBadge:openCount];
    }
    else
    {
        [self updateBadge:nil];
    }
    
    [self resetFetchedResultsController:NO];
}


#pragma mark -
#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ActivityCell *)[tableView cellForRowAtIndexPath:indexPath] path:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
