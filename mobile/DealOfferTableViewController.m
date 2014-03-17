//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
#import <MerchantDealsViewController.h>
#import "FundraiserCodeViewController.h"
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
#import "FacebookHelper.h"
#import "OperationQueueManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface DealOfferTableViewController ()
@property (strong, nonatomic) BTPaymentViewController *paymentViewController;
@property (strong, nonatomic) UINavigationController *paymentNavigationController;
@property (strong, nonatomic) FundraiserCodeViewController *fundraiserViewController;
@property (strong, nonatomic) OfferSummaryView *summaryView;
@property (strong, nonatomic) OfferActionView *actionView;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableDictionary *cacheNames;
@property (strong, nonatomic) MerchantDealsViewController *detailView;
@property (strong, nonatomic) NSString *fundraisingCode;
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

- (void)dealOfferDealsOperationComplete:(NSDictionary *)response
{
    [self setNewCacheName:offer.dealOfferId];
    [self resetFetchRestulsController];
}

- (void)purchaseOperationComplete:(NSDictionary *)response
{
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        [self.paymentViewController prepareForDismissal];
        [self.navigationController popToRootViewControllerAnimated:YES];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate presentNewDeals];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        [self.paymentViewController showErrorWithTitle:@"Payment Error" message:[error localizedDescription]];
    }

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

- (UIViewController *) getPaymentController:(BOOL)showCodeValidationByDefault
{
    
    // price formatter for the title bar
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    _paymentViewController = [BTPaymentViewController paymentViewControllerWithVenmoTouchEnabled:YES];
    _paymentViewController.delegate = self;
    _paymentViewController.vtCardViewBackgroundColor = [TaloolColor teal];
    _paymentViewController.navigationItem.title = [NSString stringWithFormat:@"Buy Deals - %@",[priceFormatter stringFromNumber:offer.price]];
    
    if (showCodeValidationByDefault || [offer isFundraiser])
    {
        if (!_fundraiserViewController)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
            _fundraiserViewController = [storyboard instantiateViewControllerWithIdentifier:@"FundraiserCodeView"];
        }
        [_fundraiserViewController setOffer:offer];
        [_fundraiserViewController setDelegate:self];
        [_fundraiserViewController setPaymentViewController:_paymentViewController];
        _fundraiserViewController.navigationItem.title = @"Code Validation";
        return _fundraiserViewController;
    }
    else
    {
        return _paymentViewController;
    }
}

#pragma mark -
#pragma mark - TaloolDealOfferActionDelegate

// Create and present a BTPaymentViewController (that has a cancel button)
- (void)buyNow:(id)sender
{
    _fundraisingCode = nil;
    [self.navigationController pushViewController:[self getPaymentController:NO] animated:YES];
}

- (void)activateCode:(id)sender
{
    _fundraisingCode = nil;
    [self.navigationController pushViewController:[self getPaymentController:YES] animated:YES];
}

#pragma mark -
#pragma mark - FundraisingCodeDelegate

- (void) handleValidCode:(NSString *)code
{
    _fundraisingCode = code;
}

- (void)handleSkipCode
{
    _fundraisingCode = nil;
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

    [[OperationQueueManager sharedInstance] startPurchaseByCardOperation:card
                                                                expMonth:expMonth
                                                                 expYear:expYear
                                                            securityCode:security
                                                                 zipCode:zip
                                                            venmoSession:session
                                                                   offer:offer
                                                              fundraiser:_fundraisingCode
                                                                delegate:self];
    
}

- (void) paymentViewController:(BTPaymentViewController *)paymentViewController didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode
{
    [[OperationQueueManager sharedInstance] startPurchaseByCodeOperation:paymentMethodCode offer:offer fundraiser:_fundraisingCode delegate:self];
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
