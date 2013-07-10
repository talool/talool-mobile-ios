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

@synthesize detailView, actionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[DealOfferHelper sharedInstance] getClosestDealOffer]==nil)
    {
        // show the modal location helper view
        HelpDealOfferLocationViewController *helper = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmLocation"];
        [helper setDelegate:self];
        [self presentViewController:helper animated:NO completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchaseCanceled)
                                                 name:IAPHelperPurchaseCanceledNotification
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) productPurchased
{
    [actionView stopSpinner];
}

- (void) purchaseCanceled
{
    [actionView stopSpinner];
}

- (void) initTableView
{
    ttDealOffer *offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
    self.navigationItem.title = offer.title;
    
    
    
    // Create the detail view that will be used for the first section header
    CGRect frame = self.view.bounds;
    detailView = [[OfferDetailView alloc]
                  initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                  offer:offer];
    
    // Create the action view that will be used for the second section header
    SKProduct *product = [[DealOfferHelper sharedInstance] getClosestProduct];
    if (product==nil)
    {
        // looks like we haven't gotten a product back from itunes, so init with
        // just the productId
        actionView = [[OfferActionView alloc]
                      initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                      productId:[DealOfferHelper sharedInstance].closestProductId];
    }
    else
    {
        actionView = [[OfferActionView alloc]
                      initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                      product:product];
    }
    
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
        return [[DealOfferHelper sharedInstance].closestDeals count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttDealOffer *offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
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
            [cell setupKeyboardAccessory:offer];
            
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
        
        ttDeal *deal = [[DealOfferHelper sharedInstance].closestDeals objectAtIndex:indexPath.row];
        [cell setDeal:deal];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ttDealOffer *offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
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
#pragma mark - HelpDealOfferLocationDelegate methods

-(void) locationSelected
{
    [self initTableView];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
