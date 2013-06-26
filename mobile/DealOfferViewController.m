//
//  DealOfferViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferViewController.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import "CustomerHelper.h"
#import "DealCell.h"
#import "TaloolIAPHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttDeal.h"

@interface DealOfferViewController ()
{
    NSNumberFormatter * _priceFormatter;
}
@end

@implementation DealOfferViewController

@synthesize offer, tableView, deals;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [buyButton useTaloolStyle];
    [self.view setBackgroundColor:[TaloolColor gray_1]];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
     
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = offer.title;
    
    NSError *error;
    deals = [offer getDeals:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext] error:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    
    descriptionLabel.text = offer.summary;
    
    NSString *expiresOn;
    if (offer.expires == nil)
    {
        expiresOn = @"";
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        expiresOn = [NSString stringWithFormat:@"Offer expires on %@",[dateFormatter stringFromDate:offer.expires]];
    }
    
    if (offer.price.intValue==0)
    {
        [buyButton setBaseColor:[TaloolColor orange]];
        [buyButton setTitle:@"Get It Free!" forState:UIControlStateNormal];
        
        savingsLabel.text = [NSString stringWithFormat:@"Offer valid in the %@ area.  %@", offer.locationName, expiresOn];
    }
    else
    {
        [buyButton setBaseColor:[TaloolColor teal]];
        NSString *label = [NSString stringWithFormat:@"Buy for $%@",offer.price];
        [buyButton setTitle:label forState:UIControlStateNormal];
        
        savingsLabel.text = [NSString stringWithFormat:@"Over $100 in savings in the %@ area.  %@", offer.locationName, expiresOn];
    }
    [logo setImageWithURL:[NSURL URLWithString:offer.imageUrl]
                      placeholderImage:[UIImage imageNamed:@"000.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 if (error !=  nil) {
                                     // TODO track these errors
                                     NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                 }
                                 
                             }];
    
    dealCountLabel.text = [NSString stringWithFormat:@"%lu Deals in this Pack", (unsigned long)[deals count]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buyAction:(id)sender
{
    if (offer.price.intValue > 0)
    {
        // TODO what if the user navigates away before the notification is received?  need to check notifications on the "my deals" screen.
        // TODO consider persisting a "pending transaction" state so we can see if there is any fall off at this point.
        NSString *productIdentifier = @"TODO"; // this should be on the Deal Offer
        TaloolIAPHelper *iapHelper = [TaloolIAPHelper sharedInstance];
        SKProduct *product = [iapHelper getProductForIdentifier:productIdentifier];
        [iapHelper buyProduct:product];
    }
    else
    {
        [self recordPurchase];
    }
}

- (void)productPurchased:(NSNotification *)notification {

    /*
     *  We got a notification of a purchase.  It has a productId, but that doesn't tell us
     *  the specific offer.  If we assume it is for the current offer, we may fulfill the 
     *  wrong deal.  It's a small edgecase, but I think it's possible
     */
    NSString * productIdentifier = notification.object;
    TaloolIAPHelper *iapHelper = [TaloolIAPHelper sharedInstance];
    SKProduct *product = [iapHelper getProductForIdentifier:productIdentifier];
    if ([product.productIdentifier isEqualToString:productIdentifier])
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

#pragma mark -
#pragma mark UITableView Delegate/Datasource

// Determines the number of sections within this table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [deals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DealCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ttDeal *deal = [deals objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell setDeal:deal];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
