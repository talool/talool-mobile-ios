//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
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
#import "FontAwesomeKit.h"

@interface DealOfferTableViewController ()
@property (nonatomic) int detailSize;
@property (nonatomic) int numberOfExtraCells;
@property (nonatomic) int numberOfExtraCellsBeforeDeals;
@end

@implementation DealOfferTableViewController

@synthesize detailSize,numberOfExtraCells,numberOfExtraCellsBeforeDeals, helpButton;

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
    [self askForHelp];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeHelp];
}

#pragma mark -
#pragma mark - Help Overlay Methods

- (void) askForHelp
{
    // if the closest deal offer is still nil, we should show the user some help
    if ([DealOfferHelper sharedInstance].closestProductId==nil)
    {
        // show the modal location helper view
        HelpDealOfferLocationViewController *helper = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmLocation"];
        [helper setDelegate:self];
        [self presentViewController:helper animated:NO completion:nil];
    }
    else if ([[DealOfferHelper sharedInstance] getClosestDealOffer]==nil || [[DealOfferHelper sharedInstance].closestDeals count] == 0)
    {
        [[DealOfferHelper sharedInstance] setSelectedBook];
        if (helpButton == nil)
        {
            self.navigationItem.title = @"Find Deals";
            helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpDealOffers.png"] forState:UIControlStateNormal];
            [self.view addSubview:helpButton];
            [self.tableView setUserInteractionEnabled:NO];
            [self.tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 320, 100) animated:NO];
        }
    }
    else
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
        [self.tableView setUserInteractionEnabled:YES];
    }
}

- (void) initTableView
{
    ttDealOffer *offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
    self.navigationItem.title = offer.title;
    
    // calculate the height of the cells in the detail section
    UIFont *font = [UIFont fontWithName:@"Verdana" size:15];
    CGSize size = [offer.summary sizeWithFont:font constrainedToSize:CGSizeMake(280, 800) lineBreakMode:NSLineBreakByWordWrapping];
    int padding = 46;
    int logoHeight = 40;
    detailSize = (size.height + logoHeight + padding);
    
    [self.tableView reloadData];
    
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
    else if ([[DealOfferHelper sharedInstance].closestDeals count]==0)
    {
        return 0;
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
            [cell setSimpleAttributedMessage:@"That's a lot of deals!" icon:FAKIconMoney icon:FAKIconMoney];
            
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

#pragma mark -
#pragma mark - HelpDealOfferLocationDelegate methods

-(void) locationSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([[DealOfferHelper sharedInstance].closestDeals count] > 0)
    {
        [self initTableView];
    }
    
}


@end
