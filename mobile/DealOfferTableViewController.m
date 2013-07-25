//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
#import "MerchantLogoView.h"
#import "OfferActionView.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealCell.h"
#import "OfferSummaryCell.h"
#import "MapCell.h"
#import "AccessCodeCell.h"
#import "FooterPromptCell.h"
#import "TaloolIAPHelper.h"
#import "DealOfferHelper.h"
#import "TextureHelper.h"
#import "TaloolUIButton.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttDeal.h"

@interface DealOfferTableViewController ()
@property (nonatomic) int detailSize;
@property (nonatomic) int numberOfExtraCells;
@property (nonatomic) int numberOfExtraCellsBeforeDeals;
@property (strong, nonatomic) OfferActionView *actionView;
@end

@implementation DealOfferTableViewController

@synthesize actionView, detailSize,numberOfExtraCells,numberOfExtraCellsBeforeDeals;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add 3 cuz we put the summary and map on top and a footer on the bottom
    numberOfExtraCells = 3;
    numberOfExtraCellsBeforeDeals = numberOfExtraCells - 1;
    
    [self initTableView];
    
    UIImageView *texture = [[UIImageView alloc] initWithFrame:self.view.bounds];
    texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:self.view.bounds.size];
    [texture setAlpha:0.15];
    [self.tableView setBackgroundView:texture];
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
    
    CGRect frame = self.view.bounds;
    
    // Create the action view that will be used for the second section header
    SKProduct *product = [[DealOfferHelper sharedInstance] getClosestProduct];
    if (product==nil)
    {
        // looks like we haven't gotten a product back from itunes, so init with
        // just the productId
        actionView = [[OfferActionView alloc]
                      initWithFrame:CGRectMake(0.0,0.0,frame.size.width,ACTION_VIEW_HEIGHT)
                      productId:[DealOfferHelper sharedInstance].closestProductId];
    }
    else
    {
        actionView = [[OfferActionView alloc]
                      initWithFrame:CGRectMake(0.0,0.0,frame.size.width,ACTION_VIEW_HEIGHT)
                      product:product];
    }
    
    // calculate the height of the cells in the detail section
    UIFont *font = [UIFont fontWithName:@"Verdana" size:15];
    CGSize size = [offer.summary sizeWithFont:font constrainedToSize:CGSizeMake(280, 800) lineBreakMode:NSLineBreakByWordWrapping];
    int padding = 46;
    int logoHeight = 40;
    detailSize = (size.height + logoHeight + padding);
    
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
        return 1; // the access code cell
    }
    else
    {
        return [[DealOfferHelper sharedInstance].closestDeals count] + numberOfExtraCells;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ttDealOffer *offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
    
    if (indexPath.section==0)
    {
        NSString *CellIdentifier = @"AccessCodeCell";
        AccessCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setupKeyboardAccessory:offer];
        
        return cell;
    }
    else
    {
        int dealCount = [[DealOfferHelper sharedInstance].closestDeals count];
        int rowCount = dealCount + numberOfExtraCells;
        
        if (indexPath.row==0)
        {
            NSString *CellIdentifier = @"DetailCell";
            OfferSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [cell setOffer:offer];
            
            return cell;
        }
        else if (indexPath.row == 1)
        {
            NSString *CellIdentifier = @"MapCell";
            MapCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [cell setDeals:[DealOfferHelper sharedInstance].closestDeals];
            
            return cell;
        }
        else if (indexPath.row == rowCount-1)
        {
            NSString *CellIdentifier = @"FooterCell";
            FooterPromptCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [cell setMessage:@"That's a lot of deals!"];
            
            return cell;
        }
        else
        {
            NSString *CellIdentifier = @"DealCell";
            DealCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            int index = indexPath.row - numberOfExtraCellsBeforeDeals;
            ttDeal *deal = [[DealOfferHelper sharedInstance].closestDeals objectAtIndex:index];
            [cell setDeal:deal];
            
            if (index == dealCount-1) {
                cell.cellBackground.image = [UIImage imageNamed:@"tableCell60Last.png"];
            }
            else
            {
                cell.cellBackground.image = [UIImage imageNamed:@"tableCell60.png"];
            }
            return cell;
        }
        
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        return ACCESS_CODE_HEIGHT;
    }
    else
    {
        if (indexPath.row == 0)
        {
            return detailSize;
        }
        else if (indexPath.row == 1)
        {
            return MAP_CELL_HEIGHT;
        }
        else
        {
            return DEAL_CELL_HEIGHT;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 0.0:ACTION_VIEW_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    if (section==0)
    {
        return nil;
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
