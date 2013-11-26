//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
#import <MerchantDealsViewController.h>
#import "OfferActionView.h"
#import "OfferSummaryView.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealOfferMerchantCell.h"
#import "OperationQueueManager.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import "AppDelegate.h"
#import "ActivateCodeViewController.h"
#import "FacebookHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface DealOfferTableViewController ()
@property (strong, nonatomic) BTPaymentViewController *paymentViewController;
@property (strong, nonatomic) OfferSummaryView *summaryView;
@property (strong, nonatomic) OfferActionView *actionView;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableDictionary *cacheNames;
@property (strong, nonatomic) MerchantDealsViewController *detailView;
@end

@implementation DealOfferTableViewController

@synthesize offer, actionView, summaryView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    actionView = [[OfferActionView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,ACTION_VIEW_HEIGHT) delegate:self];
    summaryView = [[OfferSummaryView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,SUMMARY_VIEW_HEIGHT)];
    
    _sortDescriptors = [NSArray arrayWithObjects:
                        [NSSortDescriptor sortDescriptorWithKey:@"category.name" ascending:YES],
                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                        nil];
    
    _cacheNames = [[NSMutableDictionary alloc] init];

}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"DealOfferView memory warning");
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = offer.title;
    
    [self updateDeals];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Deal Offer Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void) updateDeals
{
    [self resetFetchRestulsController];
    [[OperationQueueManager sharedInstance] startDealOfferDealsOperation:offer withDelegate:self];
    
    [actionView updateOffer:offer];
    [summaryView updateOffer:offer];
    
}

- (MerchantDealsViewController *) getDetailView:(ttMerchant *)merch
{
    if (!_detailView)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        _detailView = [storyboard instantiateViewControllerWithIdentifier:@"MerchantDeals"];
    }
    [_detailView setOffer:offer];
    [_detailView setMerchant:merch];
    return _detailView;
}


#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void)dealOfferDealsOperationComplete:(id)sender
{
    [self setNewCacheName:offer.dealOfferId];
    [self performSelectorOnMainThread:(@selector(resetFetchRestulsController)) withObject:nil waitUntilDone:NO];
    NSLog(@"Fetch controller reset after delegate called");
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
    
    NSPredicate *predicate;
    if (offer)
    {
        predicate = [NSPredicate predicateWithFormat:@"ANY deals.dealOfferId = %@", offer.dealOfferId];
    }
    
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
    //theFetchedResultsController.delegate = self;
    
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
    if (!key)
    {
        key=@"root";
    }
    NSString *name = [NSString stringWithFormat:@"%@_%@", key, [NSDate date]];
    [self.cacheNames setObject:name forKey:key];
    return name;
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((int)section==0) return 0;
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    int rows = [sectionInfo numberOfObjects];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"MerchantCell";
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
    DealOfferMerchantCell *cell = (DealOfferMerchantCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                                            forIndexPath:indexPath2];
    
    // Configure the cell...
    [self configureCell:cell path:indexPath];
    
    return cell;
    
}

- (void) configureCell:(DealOfferMerchantCell *)cell path:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ttMerchant *merchant = [self.fetchedResultsController objectAtIndexPath:indexPath2];
    [cell setMerchant:merchant];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ((int)section==0) ? SUMMARY_VIEW_HEIGHT:ACTION_VIEW_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ((int)section==0) ? summaryView:actionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ttMerchant *merchant = [_fetchedResultsController objectAtIndexPath:indexPath2];
    [self.navigationController pushViewController:[self getDetailView:merchant] animated:YES];
}

#pragma mark -
#pragma mark - TaloolDealOfferActionDelegate

// Create and present a BTPaymentViewController (that has a cancel button)
- (void)buyNow:(id)sender
{
    self.paymentViewController =
    [BTPaymentViewController paymentViewControllerWithVenmoTouchEnabled:YES];
    self.paymentViewController.delegate = self;

    self.paymentViewController.vtCardViewBackgroundColor = [TaloolColor teal];
    
    // Add paymentViewController to a navigation controller.
    UINavigationController *paymentNavigationController =
    [[UINavigationController alloc] initWithRootViewController:self.paymentViewController];
    
    // Add the cancel button
    self.paymentViewController.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:paymentNavigationController
        action:@selector(dismissModalViewControllerAnimated:)];
    
    [self.paymentViewController.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[TaloolColor dark_teal]}
                                  forState:UIControlStateNormal];

    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.paymentViewController.navigationItem.title = [NSString stringWithFormat:@"Buy Deals - %@",[priceFormatter stringFromNumber:offer.price]];
    
    [self presentViewController:paymentNavigationController animated:YES completion:nil];
}

- (void)activateCode:(id)sender
{
    ActivateCodeViewController *activateView = (ActivateCodeViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ActivateCodeView"];
    UINavigationController *activateViewNavigationController =
        [[UINavigationController alloc] initWithRootViewController:activateView];
    activateView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:activateViewNavigationController
                                             action:@selector(dismissModalViewControllerAnimated:)];
    [activateView.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[TaloolColor dark_teal]}
                                                                               forState:UIControlStateNormal];
    activateView.navigationItem.title = @"Activate Deals";
    
    [activateView setOffer:offer];
    
    [self presentViewController:activateViewNavigationController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - BTPaymentViewControllerDelegate

- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
        didSubmitCardWithInfo:(NSDictionary *)cardInfo
         andCardInfoEncrypted:(NSDictionary *)cardInfoEncrypted
{
    NSString *card = [cardInfoEncrypted objectForKey:@"card_number"];
    NSString *expMonth = [cardInfoEncrypted objectForKey:@"expiration_month"];
    NSString *expYear = [cardInfoEncrypted objectForKey:@"expiration_year"];
    NSString *security = [cardInfoEncrypted objectForKey:@"cvv"];
    NSString *zip = [cardInfoEncrypted objectForKey:@"zipcode"];
    NSString *session = [cardInfoEncrypted objectForKey:@"venmo_sdk_session"];
    NSError *err;
    
    BOOL result = [offer purchaseByCard:card
                               expMonth:expMonth
                                expYear:expYear
                           securityCode:security
                                zipCode:zip
                           venmoSession:session
                               customer:[CustomerHelper getLoggedInUser]
                                  error:&err];
    
    if (result)
    {
        [self.paymentViewController prepareForDismissal];
        [paymentViewController dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate presentNewDeals];
        }];
        
    }
    else
    {
        // show error  message
        [paymentViewController showErrorWithTitle:@"Payment Error" message:[err localizedDescription]];
    }
}

- (void) paymentViewController:(BTPaymentViewController *)paymentViewController didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode
{
    NSError *err;
    BOOL result = [offer purchaseByCode:paymentMethodCode
                               customer:[CustomerHelper getLoggedInUser]
                                  error:&err];
    
    if (result)
    {
        [self.paymentViewController prepareForDismissal];
        [paymentViewController dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate presentNewDeals];
            [FacebookHelper postOGPurchaseAction:offer];
        }];
    }
    else
    {
        // show error  message
        [paymentViewController showErrorWithTitle:@"Payment Error" message:[err localizedDescription]];
    }
}


#pragma mark -
#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
    NSIndexPath *newIndexPath2 = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath2] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(DealOfferMerchantCell *)[tableView cellForRowAtIndexPath:indexPath2] path:indexPath2];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath2] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath2] withRowAnimation:UITableViewRowAnimationFade];
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
