//
//  MyDealsViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MyDealsViewController.h"
#import "MerchantTableViewController.h"
#import "AppDelegate.h"
#import "DealOfferHelper.h"
#import "FontAwesomeKit.h"
#import "WelcomeViewController.h"
#import "FavoriteMerchantCell.h"
#import "MerchantCell.h"
#import "HeaderPromptCell.h"
#import "FooterPromptCell.h"
#import "MerchantFilterControl.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "TextureHelper.h"
#import "TaloolColor.h"
#import "MerchantSearchView.h"
#import "MerchantSearchHelper.h"
#import "ActivityStreamHelper.h"

@implementation MyDealsViewController

@synthesize helpButton;
@synthesize merchants, searchView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MarkerFelt-Thin" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor gray_2] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    [self.refreshControl addTarget:self action:@selector(refreshMerchants) forControlEvents:UIControlEventValueChanged];
    
    self.searchView = [[MerchantSearchView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)
                                         merchantSearchDelegate:self];
    
    // add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(settings:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    [settingsButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                                  forState:UIControlStateNormal];
    
    UIImageView *texture = [[UIImageView alloc] initWithFrame:self.view.bounds];
    texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:self.view.bounds.size];
    [texture setAlpha:0.15];
    [self.tableView setBackgroundView:texture];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] == nil) {
        // The user isn't logged in, so kick them to the welcome view
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
    
    self.navigationItem.title = [[CustomerHelper getLoggedInUser] getFullName];
    
    // reset with the latest list of merchants
    merchants = [MerchantSearchHelper sharedInstance].filteredMerchants;
    if ([merchants count]==0)
    {
        NSArray *unsortedMerchants = [[CustomerHelper getLoggedInUser] getMyMerchants];
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        merchants = [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    [self.tableView reloadData];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self askForHelp];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeHelp];
}


- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"merchantDeals"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttMerchant *merchant = [self.merchants objectAtIndex:([indexPath row]-1)];
        MerchantTableViewController *mvc = (MerchantTableViewController *)[segue destinationViewController];
        [mvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"welcome"])
    {
        WelcomeViewController *wvc = [segue destinationViewController];
        [wvc setHidesBottomBarWhenPushed:YES];
    }
}


#pragma mark -
#pragma mark - Help Overlay Methods

- (void) askForHelp
{
    // if merchants are still 0, we should show the user some help
    if ([merchants count]==0 && helpButton==nil)
    {
        helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpBuyDealsWithCode.png"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(closeHelp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:helpButton];
    }
    else if ([merchants count]>0)
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
    }
}

#pragma mark -
#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [merchants count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self getHeaderCell:indexPath];
    }
    else if (indexPath.row == [merchants count]+1) {
        NSString *CellIdentifier = @"FooterCell";
        FooterPromptCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setSimpleAttributedMessage:@"Need Deals? Find Deals!" icon:FAKIconArrowDown icon:FAKIconArrowDown];
        return cell;
    }
    else
    {
        return [self getMerchantCell:indexPath];
    }
}

- (UITableViewCell *)getHeaderCell:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TileTop";
    HeaderPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([merchants count]==0) {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60Last.png"];
        ttCategory *cat = [searchView.filterControl getCategoryAtSelectedIndex];
        if (cat)
        {
            [cell setMessage:[NSString stringWithFormat:@"No merchants in %@", cat.name]];
        }
        else if (searchView.filterControl.selectedSegmentIndex==1)
        {
            [cell setMessage:@"No favorite merchants"];
        }
        else
        {
            [cell setMessage:@"No merchants"];
        }
    }
    else
    {
        NSString *merch = ([merchants count]==1)?@"merchant":@"merchants";
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60.png"];
        ttCategory *cat = [searchView.filterControl getCategoryAtSelectedIndex];
        if (cat)
        {
            [cell setMessage:[NSString stringWithFormat:@"%d %@ %@", [merchants count], cat.name, merch]];
        }
        else if (searchView.filterControl.selectedSegmentIndex==1)
        {
            [cell setMessage:[NSString stringWithFormat:@"%d favorite %@", [merchants count], merch]];
        }
        else
        {
            [cell setMessage:[NSString stringWithFormat:@"%d %@", [merchants count], merch]];
        }
    }
    return cell;
}

- (UITableViewCell *)getMerchantCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the data for the cell.
    ttMerchant *merchant = [merchants objectAtIndex:indexPath.row - 1];
    
    ttCategory *cat = (ttCategory *)merchant.category;
    [cell setIcon:[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]]];
    
    [cell setName:merchant.name];

    [cell setAddress:[merchant getLocationLabel]];
    
    ttMerchantLocation *loc = [merchant getClosestLocation];
    if ([loc getDistanceInMiles] == nil || [[loc getDistanceInMiles] intValue]==0)
    {
        [cell setDistance:@"  "];
    }
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@"###0.##"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *miles = [formatter stringFromNumber:[loc getDistanceInMiles]];
        [cell setDistance: [NSString stringWithFormat:@"%@ miles",miles] ];
    }
    
    if (indexPath.row == [merchants count]) {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell90Last.png"];
    }
    else
    {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell90.png"];
    }
    
    cell.disclosureIndicator.image = [FontAwesomeKit imageForIcon:FAKIconChevronRight
                                                        imageSize:CGSizeMake(30, 30)
                                                         fontSize:14
                                                       attributes:@{ FAKImageAttributeForegroundColor:[TaloolColor gray_2] }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0 || indexPath.row == [merchants count]+1)
    {
        return 60.0;
    }
    return 90.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchView;
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshMerchants
{
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:.1];
}

- (void) updateTable
{
    [[MerchantSearchHelper sharedInstance] fetchMerchants];
}

#pragma mark -
#pragma mark - MerchantSearchDelegate methods

- (void)merchantSetChanged:(NSArray *)newMerchants sender:(id)sender
{
    merchants = newMerchants;
    [self askForHelp];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - TaloolGiftAcceptedDelegate methods

- (void) giftAccepted:(ttDealAcquire *)deal sender:(id)sender
{
    // TODO add the merchant and the deal to the customer w/o pulling everything
    [self.searchView fetchMerchants];
}

@end
