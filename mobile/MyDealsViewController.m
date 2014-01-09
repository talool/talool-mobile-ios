//
//  MyDealsViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MyDealsViewController.h"
#import "MerchantTableViewController.h"
#import "DealTableViewController.h"
#import "AppDelegate.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "WelcomeViewController.h"
#import "MerchantCell.h"
#import "Talool-API/ttCategory.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "CustomerHelper.h"
#import "LocationHelper.h"
#import "TaloolColor.h"
#import "TutorialViewController.h"
#import "OperationQueueManager.h"
#import "MerchantFilterMenu.h"
#import "SimpleHeaderView.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <TSMessages/TSMessage.h>

@interface MyDealsViewController ()
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MerchantTableViewController *detailView;
@property (strong, nonatomic) SimpleHeaderView *tableHeader;
@property (strong, nonatomic) MerchantFilterMenu *menu;
@property (strong, nonatomic) ttDealAcquire *giftedDeal;
@property (strong, nonatomic) NSString *giftId;
@property BOOL resetAfterLogin;
@end

@implementation MyDealsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TrebuchetMS" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    [self.refreshControl addTarget:self action:@selector(refreshMerchants) forControlEvents:UIControlEventValueChanged];
    
    // add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(settings:)];
    [settingsButton setTitleTextAttributes:@{NSFontAttributeName:[FontAwesomeKit fontWithSize:28], NSForegroundColorAttributeName:[TaloolColor dark_teal]}
                                  forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    
    // add the filter button
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconFilter
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(filterMenu:)];
    [filterButton setTitleTextAttributes:@{NSFontAttributeName:[FontAwesomeKit fontWithSize:28], NSForegroundColorAttributeName:[TaloolColor dark_teal]}
                                  forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    _sortDescriptors = [NSArray arrayWithObjects:
                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                        nil];
    
    [self resetFetchedResultsController:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAcceptedGift:)
                                                 name:CUSTOMER_ACCEPTED_GIFT
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePurchase:)
                                                 name:CUSTOMER_PURCHASED_DEAL_OFFER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogin:)
                                                 name:LOGIN_NOTIFICATION
                                               object:nil];


    _menu = [[MerchantFilterMenu alloc] initWithDelegate:self];
    _tableHeader = [[SimpleHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
    [_tableHeader updateTitle:[_menu getTitleAtSelectedIndex]
                     subtitle:[_menu getSubtitleAtSelectedIndex]];
    
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
    
    if (![CustomerHelper getLoggedInUser]) {
        // The user isn't logged in, so kick them to the welcome view
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
    
    // see if we lost the predicate for the fetchedResultsController
    if (!_fetchedResultsController.fetchRequest.predicate)
    {
        [self forcedClearOfTableView];
    }
    
    if (_resetAfterLogin)
    {
        [self forcedClearOfTableView];
    }
    
    [self askForHelp];
    
    self.navigationItem.title = [[CustomerHelper getLoggedInUser] getFullName];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"My Deals Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![LocationHelper sharedInstance].locationManagerStatusKnown)
    {
        // The user hasn't approved or denied location services
        [[LocationHelper sharedInstance] promptForLocationServiceAuthorization];
    }
    
    if ([self merchantCount]==0)
    {
        [TSMessage addCustomDesignFromFileWithName:@"MessageDesign.json"];
        [TSMessage showNotificationInViewController:self
                                              title:@"Welcome!"
                                           subtitle:@"You can get started with Talool by loading some deals from the Find Deals tab below."
                                               type:TSMessageNotificationTypeMessage
                                           duration:TSMessageNotificationDurationEndless
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionBottom
                                canBeDismisedByUser:NO];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TSMessage dismissActiveNotification];
}

- (void) handleUserLogin:(NSNotification *)message
{
    _resetAfterLogin = YES;
    [_menu setSelectedIndex:0];
}

- (void) handleAcceptedGift:(NSNotification *)message
{
    // prompt the user to see if they want to view their deal
    _giftId = [message.userInfo objectForKey:DELEGATE_RESPONSE_OBJECT_ID];
    BOOL isAccepted = [[message.userInfo objectForKey:DELEGATE_RESPONSE_GIFT_ACCEPTED] boolValue];
    if (isAccepted)
    {
        NSManagedObjectContext *context = [CustomerHelper getContext];
        ttGift *gift = [ttGift fetchById:_giftId context:context];
        if (gift.giftId)
        {
            // the gifted dealAcquire may not be here until the dealAcquire operation completes
            [[OperationQueueManager sharedInstance] startDealAcquireOperation:gift.deal.merchant.merchantId delegate:self];
        }
    }
}

- (void) handlePurchase:(NSNotification *)message
{
    [[OperationQueueManager sharedInstance] startMerchantOperation:self];
}

- (void)settings:(id)sender
{
    if (![self.menu isOpen] && ![self.menu isAnimating])
    {
        [self performSegueWithIdentifier:@"showSettings" sender:self];
    }
}

- (void)filterMenu:(UIBarButtonItem *)sender
{
    if (![self.menu isAnimating])
    {
        if ([self.menu isOpen])
        {
            [self.menu close];
        }
        else
        {
            [self.menu refreshCounts];
            [self.menu showFromNavigationController:self.navigationController];
        }
    }
}

- (MerchantTableViewController *) getDetailView:(ttMerchant *)merchant
{
    if (!_detailView)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        _detailView = [storyboard instantiateViewControllerWithIdentifier:@"MerchantView"];
    }
    [_detailView setMerchant:merchant];
    return _detailView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"welcome"])
    {
        WelcomeViewController *wvc = [segue destinationViewController];
        [wvc setHidesBottomBarWhenPushed:YES];
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
    NSPredicate *purgePredicate = [NSPredicate predicateWithFormat:@"SELF.name == nil"];
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
    
    NSPredicate *predicate = [_menu getPredicateAtSelectedIndex];

    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return _fetchedResultsController;
    
}

- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:MERCHANT_ENTITY_NAME
                                              inManagedObjectContext:[CustomerHelper getContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:_sortDescriptors];
    [fetchRequest setFetchBatchSize:20];
    if (predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    
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

#pragma mark -
#pragma mark - Help Overlay Methods

- (void) askForHelp
{
    // Show the welcome tutorial if they haven't seen it yet
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WELCOME_TUTORIAL_KEY])
    {
        TutorialViewController *tvc = [[TutorialViewController alloc] init];
        [tvc setTutorialKey:WELCOME_TUTORIAL_KEY];
        [tvc setHidesBottomBarWhenPushed:YES];
        [self presentViewController:tvc animated:NO completion:nil];
        [self.tabBarController setSelectedIndex:1]; // kick the user over to Find Deals
    }
    
}

- (int)merchantCount
{
    return [_fetchedResultsController.fetchedObjects count];
}


#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self merchantCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getMerchantCell:indexPath];
}

- (UITableViewCell *)getMerchantCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    MerchantCell *cell = (MerchantCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell path:indexPath];
    return cell;
}

- (void) configureCell:(MerchantCell *)cell path:(NSIndexPath *)indexPath
{
    ttMerchant *merchant = [_fetchedResultsController objectAtIndexPath:indexPath];
#warning "TODO we need to have all the deal acquires on the device before we can show the count of deals"
    int count = 0;//[merchant getAvailableDealAcquireCount:[CustomerHelper getContext]];
    [cell setMerchant:merchant remainingDeals:count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _tableHeader;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttMerchant *merch = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:[self getDetailView:merch] animated:YES];
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshMerchants
{
    [[OperationQueueManager sharedInstance] startMerchantOperation:self];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self.refreshControl endRefreshing];
}


#pragma mark -
#pragma mark - MerchantFilterDelegate methods

- (void)filterChanged:(NSPredicate *)predicate title:(NSString *)title sender:(id)sender
{
    [_tableHeader updateTitle:title subtitle:[_menu getSubtitleAtSelectedIndex]];
    [self resetFetchedResultsController:YES];
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) merchantOperationComplete:(NSDictionary *)response
{
    [self resetFetchedResultsController:NO];
}

- (void) dealAcquireOperationComplete:(NSDictionary *)response
{
    if (_giftId)
    {
        NSManagedObjectContext *context = [CustomerHelper getContext];
        ttGift *gift = [ttGift fetchById:_giftId context:context];
        if (gift.giftId)
        {
            _giftedDeal = [gift getDealAquire:context];
            if (_giftedDeal)
            {
                UIAlertView *showMe = [[UIAlertView alloc] initWithTitle:@"You've Got a new Deal!"
                                                                 message:[NSString stringWithFormat:@"We've updated your account with a new deal for %@ at %@.  Would you like to see it now?", _giftedDeal.deal.title, _giftedDeal.deal.merchant.name]
                                                                delegate:self
                                                       cancelButtonTitle:@"Yes"
                                                       otherButtonTitles:@"No",nil];
                [showMe show];
            }
        }
        _giftId = nil;
    }
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"] && _giftedDeal)
    {
        // ensure the user is on the "my deals" tab and display the new deal
        [self.navigationController.tabBarController setSelectedIndex:0];
        [self.navigationController popToRootViewControllerAnimated:NO];
        DealTableViewController *view = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"DealTableView"];
        [view setDeal:_giftedDeal];
        [self.navigationController pushViewController:view animated:YES];
        _giftedDeal = nil;
    }
    
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
            [self configureCell:(MerchantCell *)[tableView cellForRowAtIndexPath:indexPath] path:indexPath];
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
