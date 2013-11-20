//
//  FindDealsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 11/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FindDealsTableViewController.h"
#import "DealOfferTableViewController.h"
#import "DealOfferCell.h"
#import "CustomerHelper.h"
#import "Talool-API/ttDealOffer.h"
#import "TaloolColor.h"
#import "IconHelper.h"
#import "TextureHelper.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface FindDealsTableViewController ()
@property NSNumberFormatter *priceFormatter;
@end

@implementation FindDealsTableViewController

@synthesize offers;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getDealOffers];
    
    [self.refreshControl addTarget:self action:@selector(refreshOffers) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *refreshLabel = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Deals"];
    NSRange range = NSMakeRange(0,refreshLabel.length);
    [refreshLabel addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TrebuchetMS" size:12.0] range:range];
    [refreshLabel addAttribute:NSForegroundColorAttributeName value:[TaloolColor true_dark_gray] range:range];
    self.refreshControl.attributedTitle = refreshLabel;
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    NSLog(@"got %d offers",[offers count]);
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Find Deals Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewOffer"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ttDealOffer *offer = [self.offers objectAtIndex:[indexPath row]];
        DealOfferTableViewController *dovc = (DealOfferTableViewController *)[segue destinationViewController];
        [dovc setOffer:offer];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [offers count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *dummy = [[UIView alloc] init];
    return dummy;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DealOfferCell";
    DealOfferCell *cell = (DealOfferCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell path:indexPath];
    
    return cell;
}

- (void) configureCell:(DealOfferCell *)cell path:(NSIndexPath *)indexPath
{
    ttDealOffer *offer = [self.offers objectAtIndex:[indexPath row]];
    [cell.titleLabel setText:offer.title];
    [cell.summaryLabel setText:offer.summary];
    [cell.priceLabel setText:[NSString stringWithFormat:@"Price: %@",[_priceFormatter stringFromNumber:[offer price]]]];
    
    // TODO start using the new call for merchants with a geo summary
    NSNumber *deals = [NSNumber numberWithInt:70];
    NSNumber *merchants = [NSNumber numberWithInt:30];
    [cell.statsLabel setText:[NSString stringWithFormat:@"%@ deals from %@ merchants",deals, merchants]];
    
    // Use a branded background image
    if (offer.backgroundUrl)
    {
        [cell.brandingView setImageWithURL:[NSURL URLWithString:offer.backgroundUrl]
                          placeholderImage:[UIImage imageNamed:@"000"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     if (error !=  nil) {
                                         // TODO track these errors
                                         NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                     }
                             
                                 }];
    }
    else
    {
        [cell.brandingView setImage:[UIImage imageNamed:@"DealOfferBG"]];
    }
    
    // Use a branded icon image
    if (offer.iconUrl)
    {
        [cell.iconView setImageWithURL:[NSURL URLWithString:offer.iconUrl]
                          placeholderImage:[UIImage imageNamed:@"000"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     if (error !=  nil) {
                                         // TODO track these errors
                                         NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                     }
                                     
                                 }];
    }
    else
    {
        [cell.iconView setImage:[UIImage imageNamed:@"DealOfferIcon"]];
    }
}

#pragma mark -
#pragma mark - Refresh Control

- (void) refreshOffers
{
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:1];
}

- (void) updateTable
{
    [self getDealOffers];
    [self.refreshControl endRefreshing];
}

- (void) getDealOffers
{
    NSError *error;
    offers = [ttDealOffer getDealOffers:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
}

@end
