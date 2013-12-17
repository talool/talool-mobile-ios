//
//  MyDealsViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MyDealsViewController.h"
#import "MerchantTableViewController.h"
#import "AppDelegate.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "WelcomeViewController.h"
#import "MerchantCell.h"
#import "HeaderPromptCell.h"
#import "FooterPromptCell.h"
#import "MerchantFilterControl.h"
#import "Talool-API/ttCategory.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "CustomerHelper.h"
#import "LocationHelper.h"
#import "TaloolColor.h"
#import "TutorialViewController.h"
#import "MerchantSearchView.h"
#import "OperationQueueManager.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface MyDealsViewController ()
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MerchantTableViewController *detailView;
@property BOOL resetAfterLogin;
@end

@implementation MyDealsViewController

@synthesize searchView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TrebuchetMS" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    [self.refreshControl addTarget:self action:@selector(refreshMerchants) forControlEvents:UIControlEventValueChanged];
    
    self.searchView = [[MerchantSearchView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)
                                         merchantFilterDelegate:self];
    
    // add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(settings:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    [settingsButton setTitleTextAttributes:@{NSFontAttributeName:[FontAwesomeKit fontWithSize:28], NSForegroundColorAttributeName:[TaloolColor dark_teal]}
                                  forState:UIControlStateNormal];
    
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
}

- (void) handleUserLogin:(NSNotification *)message
{
    _resetAfterLogin = YES;
    [self.searchView.filterControl setSelectedSegmentIndex:0];
}

- (void) handleAcceptedGift:(NSNotification *)message
{
    [[OperationQueueManager sharedInstance] startMerchantOperation:self];
}

- (void) handlePurchase:(NSNotification *)message
{
    [[OperationQueueManager sharedInstance] startMerchantOperation:self];
}

- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"showSettings" sender:self];
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
    
    NSPredicate *predicate = [searchView.filterControl getPredicateAtSelectedIndex];

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

- (UITableViewCell *)getHeaderCell:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TileTop";
    HeaderPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ttCategory *cat = [searchView.filterControl getCategoryAtSelectedIndex];
    [cell setMessageForMerchantCount:[self merchantCount] category:cat favorite:(searchView.filterControl.selectedSegmentIndex==1)];
    return cell;
}

- (UITableViewCell *)getFooterCell:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"FooterCell";
    FooterPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setSimpleAttributedMessage:@"Need Deals? Find Deals!" icon:FAKIconArrowDown icon:FAKIconArrowDown];
    return cell;
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
    [cell setMerchant:merchant];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchView;
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

- (void)filterChanged:(NSPredicate *)predicate sender:(id)sender
{
    [self resetFetchedResultsController:YES];
    
    if (self.searchView.filterControl.selectedSegmentIndex == 0)
    {
        [self askForHelp];
    }
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) merchantOperationComplete:(NSDictionary *)response
{
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
