//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
#import "OfferDetailView.h"
#import "OfferActionView.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealCell.h"
#import "OfferSummaryCell.h"
#import "OfferMapCell.h"
#import "AccessCodeCell.h"
#import "TaloolIAPHelper.h"
#import "DealOfferHelper.h"
#import "TaloolUIButton.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttDeal.h"

@interface DealOfferTableViewController ()

@end

@implementation DealOfferTableViewController

@synthesize deals, offer, detailView, actionView, product;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // NOTE: Temporary helper to get the right payback book
    offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
    product = [[DealOfferHelper sharedInstance] getClosestProduct];
    
    self.navigationItem.title = offer.title;
    
    NSError *error;
    deals = [offer getDeals:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    
    // Create the detail view that will be used for the first section header
    CGRect frame = self.view.bounds;
    detailView = [[OfferDetailView alloc]
                  initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                  offer:offer];
    
    // Create the action view that will be used for the second section header
    actionView = [[OfferActionView alloc]
                  initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                  product:product];
    [actionView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2; // change to 3 to include the map cell
    }
    else
    {
        return [deals count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        if (indexPath.row==0)
        {
            NSString *CellIdentifier = @"DetailCell";
            OfferSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
            cell.summary.text = offer.summary;
        
            return cell;
        }
        else if (indexPath.row == 1)
        {
            NSString *CellIdentifier = @"AccessCodeCell";
            AccessCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [cell.loadDealsButton useTaloolStyle];
            [cell.loadDealsButton setBaseColor:[TaloolColor gray_3]];
            
            return cell;
        }
        else
        {
            NSString *CellIdentifier = @"MapCell";
            OfferMapCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [cell setOffer:offer];
            
            return cell;
        }
    }
    else
    {
        NSString *CellIdentifier = @"DealCell";
        DealCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        ttDeal *deal = [deals objectAtIndex:indexPath.row];
        [cell setDeal:deal];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        if (indexPath.row == 0)
        {
            // calculate the height of the cells in the detail section
            UIFont *font = [UIFont fontWithName:@"Verdana" size:14];
            CGSize size = [offer.summary sizeWithFont:font constrainedToSize:CGSizeMake(280, 800) lineBreakMode:NSLineBreakByWordWrapping];
            return (size.height + 40);
        }
        else if (indexPath.row == 1)
        {
            return 150.0;
        }
        else
        {
            return 90.0;
        }
    }
    else
    {
        return 60.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    if (section==0)
    {
        return detailView;
    }
    else
    {
        return actionView;
    }
}

#pragma mark -
#pragma mark - DealOfferPurchaseDelegate methods

-(void) buyNow:(SKProduct *)prod sender:(id)sender
{
    [[TaloolIAPHelper sharedInstance] buyProduct:prod];
}

- (void)productPurchased:(NSNotification *)notification {
    
    /*
     *  We got a notification of a purchase.  It has a productId, but that doesn't tell us
     *  the specific offer.  If we assume it is for the current offer, we may fulfill the
     *  wrong deal.  It's a small edgecase, but I think it's possible
     */
    NSString * productIdentifier = notification.object;
    TaloolIAPHelper *iapHelper = [TaloolIAPHelper sharedInstance];
    SKProduct *prod = [iapHelper getProductForIdentifier:productIdentifier];
    if ([prod.productIdentifier isEqualToString:productIdentifier])
    {
        [self recordPurchase];
    }
    
}

- (void) recordPurchase
{
    NSError *err;
    BOOL success = [[CustomerHelper getLoggedInUser] purchaseDealOffer:offer error:&err];
    NSString *title = @"purchase status";
    NSString *message;
    if (success)
    {
        message = @"OK";
    }
    else
    {
        message = @"Fail";
        // TODO handle failure.  The user has purchased, but we haven't delivered the deals.
        // * Store the offer in the user's NSUserDefaults and retry later
    }
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [errorView show];
}



@end
