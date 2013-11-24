//
//  MerchantDealsViewController.m
//  Talool
//
//  Created by Douglas McCuen on 11/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantDealsViewController.h"
#import "OfferMerchantView.h"
#import "CustomerHelper.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttDeal.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface MerchantDealsViewController ()
@property (strong, nonatomic) OfferMerchantView *merchantView;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableDictionary *cacheNames;
@end

@implementation MerchantDealsViewController

@synthesize offer, merchant;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    _merchantView = [[OfferMerchantView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,OFFER_MERCHANT_VIEW_HEIGHT)];
    
    _sortDescriptors = [NSArray arrayWithObjects:
                        [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],
                        nil];
    
    
    _cacheNames = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"DealOfferView memory warning");
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = offer.title;
    
    [self updateMerchant];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Deal Offer Merchant Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) updateMerchant
{
    [self resetFetchRestulsController];
    [_merchantView updateView:offer merchant:merchant];
    
}

#pragma mark -
#pragma mark - FetchedResultsController

- (void)resetFetchRestulsController
{
    _fetchedResultsController = nil;
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dealOfferId = %@ AND SELF.merchant.merchantId = %@", offer.dealOfferId, merchant.merchantId];
    
    _fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return _fetchedResultsController;
    
}

- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DEAL_ENTITY_NAME
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
                                                   cacheName:[self getCacheName:[NSString stringWithFormat:@"%@_%@",offer.dealOfferId,merchant.merchantId]]];
    theFetchedResultsController.delegate = self;
    
    return theFetchedResultsController;
}

- (NSString *) getCacheName:(NSString *)key
{
    NSString *name = [self.cacheNames objectForKey:key];
    if (!name) {
        name = [self setNewCacheName:key];
    }
    return name;
}

- (NSString *) setNewCacheName:(NSString *)key
{
    NSString *name = [NSString stringWithFormat:@"%@_%@", key, [[NSDate alloc] init]];
    [self.cacheNames setObject:name forKey:key];
    return name;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"DealCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell path:indexPath];
    
    return cell;
    
}

- (void) configureCell:(UITableViewCell *)cell path:(NSIndexPath *)indexPath
{
    ttDeal *deal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = deal.summary;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return OFFER_MERCHANT_VIEW_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _merchantView;
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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] path:indexPath];
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
