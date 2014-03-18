//
//  MerchantTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantTableViewController.h"
#import "DealTableViewController.h"
#import "MerchantLocationViewController.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "DealAcquireCell.h"
#import "MapCell.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttCustomer.h"
#import <OperationQueueManager.h>
#import "MerchantActionBar3View.h"
#import "TaloolMobileWebViewController.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface MerchantTableViewController ()

@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) MerchantActionBar3View *actionBar3View;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) DealTableViewController *dealViewController;
@property (strong, nonatomic) MerchantLocationViewController *locationViewController;

@end

@implementation MerchantTableViewController

@synthesize merchant, actionBar3View;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TrebuchetMS" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    CGRect frame = self.view.bounds;

    actionBar3View = [[MerchantActionBar3View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT) delegate:self];
    
    // add the settings button
    UIBarButtonItem *likeButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconHeartEmpty
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(likeAction)];
    self.navigationItem.rightBarButtonItem = likeButton;
    [likeButton setTitleTextAttributes:@{NSFontAttributeName:[FontAwesomeKit fontWithSize:26], NSForegroundColorAttributeName: [TaloolColor dark_teal]}
                              forState:UIControlStateNormal];
    
    _sortDescriptors = [NSArray arrayWithObjects:
                       [NSSortDescriptor sortDescriptorWithKey:@"invalidated" ascending:YES],
                       [NSSortDescriptor sortDescriptorWithKey:@"deal.title" ascending:YES],
                       nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Merchant View memory warning");
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = merchant.name;
    
    [actionBar3View setMerchant:merchant];
    
    [self setLikeLabel];
    
    [[OperationQueueManager sharedInstance] startDealAcquireOperation:merchant.merchantId delegate:self];

    _fetchedResultsController = nil;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Merchant Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void) likeAction
{
    // change the value and label right away, then persist it with the service call
    BOOL newvalue = ![merchant isFavorite];
    [merchant setIsFav:[NSNumber numberWithBool:newvalue]];
    [self setLikeLabel];
    
    [[OperationQueueManager sharedInstance] startFavoriteOperation:merchant.merchantId
                                                        isFavorite:newvalue
                                                          delegate:self];
}

- (void) setLikeLabel
{
    UIBarButtonItem *likeButton = self.navigationItem.rightBarButtonItem;
    if ([merchant isFavorite])
    {
        likeButton.title = FAKIconHeart;
    }
    else
    {
        likeButton.title = FAKIconHeartEmpty;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showWebsite"])
    {
        ttMerchantLocation *loc = merchant.closestLocation;
        [[segue destinationViewController] setMobileWebUrl:loc.websiteUrl];
        [[segue destinationViewController] setViewTitle:merchant.name];
    }
}

- (DealTableViewController *) getDealView:(ttDealAcquire *)deal
{
    if (!_dealViewController)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        _dealViewController = [storyboard instantiateViewControllerWithIdentifier:@"DealTableView"];
    }
    [_dealViewController setDeal:deal];
    return _dealViewController;
}

- (MerchantLocationViewController *) getLocationlView
{
    if (!_locationViewController)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        _locationViewController = [storyboard instantiateViewControllerWithIdentifier:@"MerchantLocationView"];
    }
    [_locationViewController setMerchant:merchant];
    return _locationViewController;
}

#pragma mark -
#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    [self.tableView reloadData];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deal.merchant.merchantId = %@", merchant.merchantId];
    
    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return _fetchedResultsController;
    
}

- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DEAL_ACQUIRE_ENTITY_NAME
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

- (int)dealCount
{
    return [_fetchedResultsController.fetchedObjects count];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self dealCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getDealCell:indexPath];
}

- (UITableViewCell *) getDealCell:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"RewardCell";
    
    DealAcquireCell *cell = (DealAcquireCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell path:indexPath];
	
    return cell;
}

- (void) configureCell:(DealAcquireCell *)cell path:(NSIndexPath *)indexPath
{
    ttDealAcquire *deal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setDeal:deal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return actionBar3View;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttDealAcquire *deal = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:[self getDealView:deal] animated:YES];
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshDeals
{
    // Override in subclass to hit the service
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
    [[OperationQueueManager sharedInstance] startDealAcquireOperation:merchant.merchantId delegate:self];
}

- (void) updateTable
{
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - TaloolMerchantActionDelegate methods

- (void)openMap:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MERCHANT"
                                                          action:@"ActionButton"
                                                           label:@"Map"
                                                           value:nil] build]];
    
    [self.navigationController pushViewController:[self getLocationlView] animated:YES];
}

- (void)placeCall:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MERCHANT"
                                                          action:@"ActionButton"
                                                           label:@"Call"
                                                           value:nil] build]];
    
    ttMerchantLocation *loc = merchant.closestLocation;
    
    NSMutableString *cleanPhoneNumber = [NSMutableString
                                       stringWithCapacity:10];
    
    for (int i=0; i<[loc.phone length]; i++) {
        if (isdigit([loc.phone characterAtIndex:i])) {
            [cleanPhoneNumber appendFormat:@"%c",[loc.phone characterAtIndex:i]];
        }
    }
    
    NSLog(@"calling %@",cleanPhoneNumber);
    NSString *phoneNumber = [@"tel://" stringByAppendingString:cleanPhoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)visitWebsite:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MERCHANT"
                                                          action:@"ActionButton"
                                                           label:@"Website"
                                                           value:nil] build]];
    
    [self performSegueWithIdentifier:@"showWebsite" sender:self];
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
            [self configureCell:(DealAcquireCell *)[tableView cellForRowAtIndexPath:indexPath] path:indexPath];
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



#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void)dealAcquireOperationComplete:(NSDictionary *)response
{
    NSError *error;
    _fetchedResultsController = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
}

- (void) favoriteOperationComplete:(NSDictionary *)response
{
    [[CustomerHelper getContext] refreshObject:merchant mergeChanges:YES];
    [self setLikeLabel];
}

@end
