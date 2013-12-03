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
#import "MerchantSearchView.h"
#import "OperationQueueManager.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface MyDealsViewController ()
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MerchantTableViewController *detailView;
@end

@implementation MyDealsViewController

@synthesize helpButton, searchView;

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
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    [self.tableView reloadData];
    
    NSString *logoutNotification = LOGOUT_NOTIFICATION;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogout)
                                                 name:logoutNotification
                                               object:nil];
    NSString *giftNotification = CUSTOMER_ACCEPTED_GIFT;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAcceptedGift)
                                                 name:giftNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"My Deals memory warning");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![CustomerHelper getLoggedInUser]) {
        // The user isn't logged in, so kick them to the welcome view
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
    
    self.navigationItem.title = [[CustomerHelper getLoggedInUser] getFullName];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"My Deals Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self askForHelp];
    
    if (![LocationHelper sharedInstance].locationManagerStatusKnown)
    {
        // The user hasn't approved or denied location services
        [[LocationHelper sharedInstance] promptForLocationServiceAuthorization];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeHelp];
}

- (void) handleUserLogout
{
    _fetchedResultsController = nil;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
}

- (void) handleAcceptedGift
{
    _fetchedResultsController = nil;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
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

#pragma mark -
#pragma mark - Help Overlay Methods

- (void) askForHelp
{
    // if merchants are still 0, we should show the user some help
    if ([self merchantCount]==0 && helpButton==nil && [self.searchView.filterControl selectedSegmentIndex]==0)
    {
        helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpBuyDealsWithCode.png"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(closeHelp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:helpButton];
    }
    else if ([self merchantCount]>0)
    {
        [self closeHelp];
    }
}

- (void)closeHelp
{
    if (helpButton)
    {
        [helpButton removeFromSuperview];
        helpButton = nil;
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
    /*
    if (indexPath.row == 0)
    {
        return [self getHeaderCell:indexPath];
    }
    else if (indexPath.row == [self merchantCount]+1)
    {
        return [self getFooterCell:indexPath];
    }
    else
    {
        return [self getMerchantCell:indexPath];
    }
    */
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
    ttMerchant *merchant = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setMerchant:merchant];
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0 || indexPath.row == [self merchantCount]+1)
    {
        return 60.0;
    }
    return 90.0;
}
*/
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
    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    [self.tableView reloadData];
    
    if (!predicate)
    {
        [self askForHelp];
    }
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) merchantOperationComplete:(NSDictionary *)response
{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
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
