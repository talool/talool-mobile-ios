//
//  DealOfferTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferTableViewController.h"
#import "AppDelegate.h"
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
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttDeal.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "AppDelegate.h"
#import "ActivateCodeViewController.h"
#import "FacebookHelper.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface DealOfferTableViewController ()
@property (nonatomic) int detailSize;
@property (nonatomic) int numberOfExtraCells;
@property (nonatomic) int numberOfExtraCellsBeforeDeals;
@property (strong, nonatomic) BTPaymentViewController *paymentViewController;
@property (strong, nonatomic) OfferActionView *actionView;
@property (strong, nonatomic) ttDealOffer *offer;
@end

@implementation DealOfferTableViewController

@synthesize offer, actionView, detailSize,numberOfExtraCells,numberOfExtraCellsBeforeDeals, helpButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add 3 cuz we put the summary and map on top and a footer on the bottom
    numberOfExtraCells = 3;
    numberOfExtraCellsBeforeDeals = numberOfExtraCells - 1;
    
    [self initTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self askForHelp];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Deal Offer Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
    offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
    self.navigationItem.title = offer.title;
    
    CGRect frame = self.view.bounds;
    actionView = [[OfferActionView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,ACTION_VIEW_HEIGHT) offer:offer delegate:self];
    
    // calculate the height of the cells in the detail section
    UIFont *font = [UIFont fontWithName:@"Verdana" size:15];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    CGSize size = [offer.summary boundingRectWithSize:CGSizeMake(280, 800)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil].size;
    
    int padding = 24;
    detailSize = (size.height + padding);
    
    [self.tableView reloadData];
    
}


#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[DealOfferHelper sharedInstance].closestDeals count]==0)
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ACTION_VIEW_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return actionView;
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

@end
