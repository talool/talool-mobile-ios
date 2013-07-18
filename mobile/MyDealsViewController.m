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
    
    // Creating view for extending background color
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView* bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [TaloolColor gray_5];
    UIImageView *texture = [[UIImageView alloc] initWithImage:[TextureHelper getTextureWithColor:[TaloolColor gray_4] size:frame.size]];
    [texture setAlpha:0.2];
    [bgView addSubview:texture];
    
    // Adding the view below the refresh control
    [self.tableView insertSubview:bgView atIndex:0];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.loginViewController registerAuthDelegate:self];
    
    self.searchView = [[MerchantSearchView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)
                                         merchantSearchDelegate:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    if ([CustomerHelper getLoggedInUser] == nil) {
        // The user isn't logged in, so kick them to the welcome view
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
    
    self.navigationItem.title = [[CustomerHelper getLoggedInUser] getFullName];
    
    // add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(settings:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    [settingsButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                                  forState:UIControlStateNormal];
    
    // load any merchants connected to this customer from the context
    if ([merchants count]==0)
    {
        NSArray *unsortedMerchants = [[CustomerHelper getLoggedInUser] getMyMerchants];
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        merchants = [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    [self askForHelp];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        ttMerchant *merchant = [self.merchants objectAtIndex:[indexPath row]];
        MerchantTableViewController *mvc = (MerchantTableViewController *)[segue destinationViewController];
        [mvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"welcome"])
    {
        WelcomeViewController *wvc = [segue destinationViewController];
        [wvc registerAuthDelegate:self];
        [wvc setHidesBottomBarWhenPushed:YES];
    }
}


#pragma mark -
#pragma mark - Help Overlay Methods

- (void) askForHelp
{
    // if merchants are still 0, we should show the user some help
    if ([merchants count]==0)
    {
        helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpBuyDealsWithCode.png"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(closeHelp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:helpButton];
    }
    else
    {
        // check if there are deals
        if (![[CustomerHelper getLoggedInUser] hasDeals:[CustomerHelper getContext]])
        {
            helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [helpButton setBackgroundImage:[UIImage imageNamed:@"HelpBuyDeals.png"] forState:UIControlStateNormal];
            [helpButton addTarget:self action:@selector(closeHelp) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:helpButton];
        }
    }
}

- (void)closeHelp
{
    if (helpButton)
    {
        [helpButton removeFromSuperview];
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
    return [merchants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MerchantCell";
    
    FavoriteMerchantCell *cell = (FavoriteMerchantCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the data for the cell.
    ttMerchant *merchant = [merchants objectAtIndex:indexPath.row];
    //[cell setMerchant:merchant];
    ttCategory *cat = (ttCategory *)merchant.category;
    ttMerchantLocation *loc = [merchant getClosestLocation];
    
    CategoryHelper *helper = [[CategoryHelper alloc] init];
    [cell setIcon:[helper getIcon:[cat.categoryId intValue]]];
    [cell setName:merchant.name];
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
    [cell setAddress:[merchant getLocationLabel]];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchView;
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshMerchants
{
    // Override in subclass to hit the service
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [searchView fetchMerchants];
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - MerchantSearchDelegate methods

- (void)merchantSetChanged:(NSArray *)newMerchants sender:(id)sender
{
    merchants = newMerchants;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - TaloolAuthenticationDelegate methods

- (void) customerLoggedIn:(id)sender
{
    self.merchants = [NSArray arrayWithObjects:nil];
    [self.searchView fetchMerchants];
    [[DealOfferHelper sharedInstance] reset];
    NSLog(@"new user with %d merchants", [self.merchants count]);
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - TaloolGiftAcceptedDelegate methods

- (void) giftAccepted:(ttDealAcquire *)deal sender:(id)sender
{
    // TODO add the merchant and the deal to the customer w/o pulling everything
    [self.searchView fetchMerchants];
}

@end
