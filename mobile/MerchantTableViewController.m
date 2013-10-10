//
//  MerchantTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantTableViewController.h"
#import "DealTableViewController.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"
#import "DealAcquireCell.h"
#import "MapCell.h"
#import "DealImageCell.h"
#import "FooterPromptCell.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttCustomer.h"
#import "HelpNetworkFailureViewController.h"
#import "MerchantActionBar3View.h"
#import "TaloolMobileWebViewController.h"
#import "talool-api-ios/GAI.h"

@interface MerchantTableViewController ()

@property (nonatomic, retain) NSArray *deals;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (strong, nonatomic) MerchantActionBar3View *actionBar3View;

@end

@implementation MerchantTableViewController

@synthesize deals, sortDescriptors, merchant, actionBar3View;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MarkerFelt-Thin" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    CGRect frame = self.view.bounds;

    actionBar3View = [[MerchantActionBar3View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT) delegate:self];
    
    // add the settings button
    UIBarButtonItem *likeButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconHeartEmpty
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(likeAction)];
    self.navigationItem.rightBarButtonItem = likeButton;
    [likeButton setTitleTextAttributes:@{NSFontAttributeName:[FontAwesomeKit fontWithSize:20], NSForegroundColorAttributeName: [TaloolColor dark_teal]}
                              forState:UIControlStateNormal];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = merchant.name;
    
    NSString *url = [merchant getClosestLocation].imageUrl;
    [actionBar3View setMerchantImage:url];
    
    [self setLikeLabel];
    
    NSError *err = nil;
    deals = [[CustomerHelper getLoggedInUser] getMyDealsForMerchant:merchant context:[CustomerHelper getContext] error:&err];
    
    sortDescriptors = [NSArray arrayWithObjects:
                       [NSSortDescriptor sortDescriptorWithKey:@"invalidated" ascending:YES],
                       [NSSortDescriptor sortDescriptorWithKey:@"deal.title" ascending:YES],
                       nil];
    
    deals = [[[NSArray alloc] initWithArray:deals] sortedArrayUsingDescriptors:sortDescriptors];
    
    if ([deals count]==0)
    {
        // Show the network error message
        HelpNetworkFailureViewController *helper = [self.storyboard instantiateViewControllerWithIdentifier:@"NetworkFailure"];
        [helper setMessageType:DealsNotLoaded];
        [self presentViewController:helper animated:NO completion:nil];
    }
    else
    {
        [self.tableView reloadData];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Merchant Screen"];
    
}

- (void) likeAction
{
    if ([merchant isFavorite])
    {
        [merchant unfavorite:[CustomerHelper getLoggedInUser]];
    }
    else
    {
        [merchant favorite:[CustomerHelper getLoggedInUser]];
        [FacebookHelper postOGLikeAction:[merchant getClosestLocation]];
    }
    [self setLikeLabel];
}

- (void) setLikeLabel
{
    UIBarButtonItem *likeButton = self.navigationItem.rightBarButtonItem;
    if ([merchant isFavorite])
    {
        likeButton.title = FAKIconHeart;
    }
    else
    {
        likeButton.title = FAKIconHeartEmpty;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"])
    {
        [[segue destinationViewController] setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"showWebsite"])
    {
        ttMerchantLocation *loc = [merchant getClosestLocation];
        [[segue destinationViewController] setMobileWebUrl:loc.websiteUrl];
        [[segue destinationViewController] setViewTitle:merchant.name];
    }
    else if ([[segue identifier] isEqualToString:@"showDeal"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttDealAcquire *deal = [deals objectAtIndex:[indexPath row]];
        DealTableViewController *dtvc = [segue destinationViewController];
        [dtvc setDeal:deal];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // add 1 cuz the footer is at the bottom
    return [deals count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [deals count]) {
        NSString *CellIdentifier = @"FooterCell";
        FooterPromptCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setSimpleAttributedMessage:@"Need Deals? Find Deals!" icon:FAKIconArrowDown icon:FAKIconArrowDown];
        return cell;
    }
    else
    {
        return [self getDealCell:indexPath];
    }
}

- (UITableViewCell *) getDealCell:(NSIndexPath *)indexPath
{
    
    // TODO change the bg image based on the position
    
    static NSString *CellIdentifier = @"RewardCell";
    
    DealAcquireCell *cell = (DealAcquireCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the data for the cell.
    ttDealAcquire *deal = (ttDealAcquire *)[deals objectAtIndex:indexPath.row];
    [cell setDeal:deal];
    
    NSString *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    if ([deal hasBeenRedeemed])
    {
        date = [NSString stringWithFormat:@"Redeemed on %@", [dateFormatter stringFromDate:deal.redeemed]];
        
    }
    else if ([deal hasBeenShared])
    {
        if (deal.shared == nil)
        {
            date = @"Shared";
        }
        else
        {
            date = [NSString stringWithFormat:@"Shared on %@", [dateFormatter stringFromDate:deal.shared]];
        }
        
    }
    else if ([deal hasExpired])
    {
        date = [NSString stringWithFormat:@"Expired on %@", [dateFormatter stringFromDate:deal.deal.expires]];
    }
    
    NSDictionary* strikethrough = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
    NSDictionary* normaltext = @{};
    
    NSString *dealTitle = deal.deal.title;
    
    if ([deal hasBeenRedeemed] || [deal hasBeenShared] || [deal hasExpired])
    {
        cell.iconView.image = [IconHelper getImageForIcon:FAKIconMoney color:[TaloolColor gray_1]];

        cell.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:dealTitle attributes:strikethrough];
    }
    else
    {
        if (deal.deal.expires ==  nil)
        {
            date = @"Never Expires";
        }
        else
        {
            date = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:deal.deal.expires]];
        }
        cell.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:dealTitle attributes:normaltext];
        cell.iconView.image = [IconHelper getImageForIcon:FAKIconMoney color:[TaloolColor green]];
    }
    
    cell.dateLabel.text = date;
    
    if (indexPath.row == [deals count]) {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60Last.png"];
    }
    else
    {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60.png"];
    }

    
    cell.disclosureIndicator.image = [FontAwesomeKit imageForIcon:FAKIconChevronRight
                                                        imageSize:CGSizeMake(30, 30)
                                                         fontSize:14
                                                       attributes:@{ FAKImageAttributeForegroundColor:[TaloolColor gray_2] }];
     

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return actionBar3View;
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshDeals
{
    // Override in subclass to hit the service
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    NSError *error;
    NSArray *dealsFromServer = [[CustomerHelper getLoggedInUser] refreshMyDealsForMerchant:merchant
                                                                                  context:[CustomerHelper getContext]
                                                                                error:&error];
    
    [self.refreshControl endRefreshing];
    
    if (error.code) {
        // if there was error we don't want to blow away anything that was already there.
        return;
    }
    
    NSLog(@"refreshed %d deals",[dealsFromServer count]);
    sortDescriptors = [NSArray arrayWithObjects:
                       [NSSortDescriptor sortDescriptorWithKey:@"invalidated" ascending:YES],
                       [NSSortDescriptor sortDescriptorWithKey:@"deal.title" ascending:YES],
                       nil];
    
    deals = [[[NSArray alloc] initWithArray:dealsFromServer] sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - TaloolMerchantActionDelegate methods

- (void)openMap:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"MERCHANT"
                        withAction:@"ActionButton"
                         withLabel:@"Map"
                         withValue:nil];
    
    [self performSegueWithIdentifier:@"showMap" sender:self];
}

- (void)placeCall:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"MERCHANT"
                        withAction:@"ActionButton"
                         withLabel:@"Call"
                         withValue:nil];
    
    ttMerchantLocation *loc = [merchant getClosestLocation];
    
    NSMutableString *cleanPhoneNumber = [NSMutableString
                                       stringWithCapacity:10];
    
    for (int i=0; i<[loc.phone length]; i++) {
        if (isdigit([loc.phone characterAtIndex:i])) {
            [cleanPhoneNumber appendFormat:@"%c",[loc.phone characterAtIndex:i]];
        }
    }
    
    NSLog(@"calling %@",cleanPhoneNumber);
    NSString *phoneNumber = [@"tel://" stringByAppendingString:cleanPhoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)visitWebsite:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"MERCHANT"
                        withAction:@"ActionButton"
                         withLabel:@"Website"
                         withValue:nil];
    
    [self performSegueWithIdentifier:@"showWebsite" sender:self];
}

@end
