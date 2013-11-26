//
//  FindDealsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 11/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FindDealsTableViewController.h"
#import "DealOfferTableViewController.h"
#import "DealOfferCell.h"
#import "CustomerHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttDealOfferGeoSummary.h"
#import "TaloolColor.h"
#import "IconHelper.h"
#import "TextureHelper.h"
#import "OperationQueueManager.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface FindDealsTableViewController ()
@property NSNumberFormatter *priceFormatter;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) DealOfferTableViewController *detailView;
@property (strong, nonatomic) NSString *cacheName;
@end

@implementation FindDealsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.refreshControl addTarget:self action:@selector(refreshOffers) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TrebuchetMS" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    _sortDescriptors = [NSArray arrayWithObjects:
                            [NSSortDescriptor sortDescriptorWithKey:@"distanceInMeters" ascending:YES],
                            [NSSortDescriptor sortDescriptorWithKey:@"dealOffer.title" ascending:YES],
                            nil];
    
    [self resetFetchRestulsController];
    [[OperationQueueManager sharedInstance] startDealOfferOperation:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"FindDeals memory warning");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetFetchRestulsController];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Find Deals Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (DealOfferTableViewController *) getDetailView:(ttDealOffer *)offer
{
    if (!_detailView)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        _detailView = [storyboard instantiateViewControllerWithIdentifier:@"DealOfferView"];
    }
    [_detailView setOffer:offer];
    return _detailView;
}

- (void) setNewCacheName
{
    _cacheName = [NSString stringWithFormat:@"%@_%@",@"FD",[NSDate date]];
}

#pragma mark -
#pragma mark - FetchedResultsController

- (void)resetFetchRestulsController
{
    _fetchedResultsController = nil;
    [self setNewCacheName];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    [self.tableView reloadData];
    
    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    return _fetchedResultsController;
    
}

- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:DEAL_OFFER_GEO_SUMMARY_ENTITY_NAME inManagedObjectContext:[CustomerHelper getContext]];
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
                                                   cacheName:_cacheName];
    theFetchedResultsController.delegate = self;
    
    return theFetchedResultsController;
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *dummy = [[UIView alloc] init];
    return dummy;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DealOfferCell";
    DealOfferCell *cell = (DealOfferCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell path:indexPath];
    
    return cell;
}

- (void) configureCell:(DealOfferCell *)cell path:(NSIndexPath *)indexPath
{
    ttDealOfferGeoSummary *offerSummary = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ttDealOffer *offer = (ttDealOffer *)offerSummary.dealOffer;

    [cell.titleLabel setText:offer.title];
    [cell.summaryLabel setText:offer.summary];
    [cell.priceLabel setText:[NSString stringWithFormat:@"Price: %@",[_priceFormatter stringFromNumber:[offer price]]]];
    
    [cell.statsLabel setText:[NSString stringWithFormat:@"%@ deals from %@ merchants",
                              offerSummary.totalDeals,
                              offerSummary.totalMerchants]];
    
    // Use a branded background image
    if (offer.backgroundUrl)
    {
        [cell.brandingView setImageWithURL:[NSURL URLWithString:offer.backgroundUrl]
                          placeholderImage:[UIImage imageNamed:@"000"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     if (error !=  nil) {
                                         // TODO track these errors
                                         NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                     }
                             
                                 }];
    }
    else
    {
        [cell.brandingView setImage:[UIImage imageNamed:@"DealOfferBG"]];
    }
    
    // Use a branded icon image
    if (offer.iconUrl)
    {
        [cell.iconView setImageWithURL:[NSURL URLWithString:offer.iconUrl]
                          placeholderImage:[UIImage imageNamed:@"000"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     if (error !=  nil) {
                                         // TODO track these errors
                                         NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                     }
                                     
                                 }];
    }
    else
    {
        [cell.iconView setImage:[UIImage imageNamed:@"DealOfferIcon"]];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttDealOfferGeoSummary *offerSummary = [_fetchedResultsController objectAtIndexPath:indexPath];
    ttDealOffer *offer = (ttDealOffer *)offerSummary.dealOffer;
    [self.navigationController pushViewController:[self getDetailView:offer] animated:YES];
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshOffers
{
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
    [[OperationQueueManager sharedInstance] startDealOfferOperation:self];
}

- (void) updateTable
{
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void)dealOfferOperationComplete:(id)sender
{
    [self resetFetchRestulsController];
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
            [self configureCell:(DealOfferCell *)[tableView cellForRowAtIndexPath:indexPath] path:indexPath];
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
