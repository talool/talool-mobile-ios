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
#import "AppDelegate.h"

@interface DealOfferTableViewController ()
@property (nonatomic) int detailSize;
@property (nonatomic) int numberOfExtraCells;
@property (nonatomic) int numberOfExtraCellsBeforeDeals;
@property (strong, nonatomic) BTPaymentViewController *paymentViewController;
@property (strong, nonatomic) OfferActionView *actionView;
@end

@implementation DealOfferTableViewController

@synthesize actionView, detailSize,numberOfExtraCells,numberOfExtraCellsBeforeDeals, helpButton;

#warning create a secure page for posting CC data to,  Should be in the API
//#define SAMPLE_CHECKOUT_BASE_URL @"http://sample-checkout.herokuapp.com"
//#define SAMPLE_CHECKOUT_BASE_URL @"http://www2.talool.com:8080"
#define SAMPLE_CHECKOUT_BASE_URL @"http://dev-www.talool.com"

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
    
    CGRect frame = self.view.bounds;
    actionView = [[OfferActionView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,ACTION_VIEW_HEIGHT) productId:[DealOfferHelper sharedInstance].closestProductId delegate:self];
    
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
    
    // Add paymentViewController to a navigation controller.
    UINavigationController *paymentNavigationController =
    [[UINavigationController alloc] initWithRootViewController:self.paymentViewController];
    
    // Add the cancel button
    self.paymentViewController.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:paymentNavigationController
     action:@selector(dismissModalViewControllerAnimated:)];
    
    [self presentViewController:paymentNavigationController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - BTPaymentViewControllerDelegate

// When a user types in their credit card information correctly, the BTPaymentViewController sends you
// card details via the `didSubmitCardWithInfo` delegate method.
//
// NB: you receive raw, unencrypted info in the `cardInfo` dictionary, but
// for easy PCI Compliance, you should use the `cardInfoEncrypted` dictionary
// to securely pass data through your servers to the Braintree Gateway.
#warning does this mean the app uses excryption?
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
        didSubmitCardWithInfo:(NSDictionary *)cardInfo
         andCardInfoEncrypted:(NSDictionary *)cardInfoEncrypted
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/mobile/payment/save", SAMPLE_CHECKOUT_BASE_URL]];
    [self savePaymentInfoToServer:cardInfoEncrypted url:url];
}

// When a user adds a saved card from Venmo Touch to your app, the BTPaymentViewController sends you
// a paymentMethodCode that you can pass through your servers to the Braintree Gateway to
// add the full card details to your Vault.

- (void) paymentViewController:(BTPaymentViewController *)paymentViewController didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode
{
    NSMutableDictionary *paymentInfo = [NSMutableDictionary dictionaryWithObject:paymentMethodCode
                                                                          forKey:@"venmo_sdk_payment_method_code"];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/mobile/payment/use", SAMPLE_CHECKOUT_BASE_URL]];
    
    [self savePaymentInfoToServer:paymentInfo url:url];
}

#pragma mark - Networking

// The following example code demonstrates how to pass encrypted card data from the app to your
// server (your server will then have to send it to the Braintree Gateway). For a fully working
// example of how to proxy data through your server to the Braintree Gateway, see:
//    1. the braintree_ios Server Side Integration tutorial [https://touch.venmo.com/server-integration-tutorial/]
//    2. and the sample-checkout-heroku Github project [link]

// Pass payment info (eg card data) from the client to your server (and then to the Braintree Gateway).
// If card data is valid and added to your Vault, display a success message, and dismiss the BTPaymentViewController.
// If saving to your Vault fails, display an error message to the user via `BTPaymentViewController showErrorWithTitle`
// Saving to your Vault may fail, for example when
// * CVV verification does not pass
// * AVS verification does not pass
// * The card number was a valid Luhn number, but nonexistent or no longer valid

- (void) savePaymentInfoToServer:(NSDictionary *)paymentInfo url:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // You need a customer id in order to save a card to the Braintree vault.
    [paymentInfo setValue:[CustomerHelper getLoggedInUser].customerId forKey:@"customer_id"];
    
    request.HTTPBody = [self postDataFromDictionary:paymentInfo];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError)
     {
         //NSLog(@"payment response: %@ %@",response.description, body.description);
         NSError *err = nil;
         if (!response && requestError) {
             NSLog(@"requestError: %@", requestError);
             [self.paymentViewController showErrorWithTitle:@"Error" message:@"Unable to reach the network."];
             return;
         }
         
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:&err];
         //NSLog(@"saveCardToServer: paymentInfo: %@ response: %@, error: %@", paymentInfo, responseDictionary, requestError);
         //NSLog(@"saveCardToServer: response: %@", responseDictionary);
         
         if ([[responseDictionary valueForKey:@"success"] isEqualToNumber:@1])
         {
             // Don't forget to call the cleanup method,
             // `prepareForDismissal`, on your `BTPaymentViewController`
             [self.paymentViewController prepareForDismissal];
             // Now you can dismiss and tell the user everything worked.
             [self dismissViewControllerAnimated:YES completion:^(void) {
            
                 ttDealOffer *offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
                 NSError *err;
                 BOOL success = [[CustomerHelper getLoggedInUser] purchaseDealOffer:offer error:&err];
                 if (success)
                 {
                     AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                     [appDelegate presentNewDeals];
                 }
                 else
                 {
#warning this is why all the payment processing needs to happen in the API
                 }
                 
             }];
             
         }
         else
         {
             // The card did not save correctly, so show the error from server with convenenience method `showErrorWithTitle`
             [self.paymentViewController showErrorWithTitle:@"Error saving your card" message:[self messageStringFromResponse:responseDictionary]];
         }
     }];
}

// Some boiler plate networking code below.

- (NSString *) messageStringFromResponse:(NSDictionary *)responseDictionary {
    return [responseDictionary valueForKey:@"message"];
}

// Construct URL encoded POST data from a dictionary
- (NSData *)postDataFromDictionary:(NSDictionary *)params {
    NSMutableString *data = [NSMutableString string];
    
    for (NSString *key in params) {
        NSString *value = [params objectForKey:key];
        if (value == nil) {
            continue;
        }
        if ([value isKindOfClass:[NSString class]]) {
            value = [self URLEncodedStringFromString:value];
        }
        
        [data appendFormat:@"%@=%@&", [self URLEncodedStringFromString:key], value];
    }
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

// This method is adapted from from Dave DeLong's example at
// http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string ,
// and protected by http://creativecommons.org/licenses/by-sa/3.0/
- (NSString *) URLEncodedStringFromString: (NSString *)string {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@end
