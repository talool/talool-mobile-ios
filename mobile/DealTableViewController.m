//
//  DealTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealTableViewController.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "DealActionBar3View.h"
#import "BarCodeCell.h"
#import "DealDetailCell.h"
#import "HeroImageCell.h"
#import "DealLayoutState.h"
#import "DefaultDealLayoutState.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "ZXingObjC/ZXingObjC.h"


@interface DealTableViewController ()

@end

@implementation DealTableViewController

@synthesize deal, offer, friendCache, dealLayout, actionBar3View;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _merchantLocation = nil;
    _customerLocation = nil;
    
    CGRect frame = self.view.bounds;
    actionBar3View = [[DealActionBar3View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,75.0)
                                                          deal:deal
                                                      delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = deal.deal.merchant.name;
    
    NSError *error;
    NSString *doId = deal.deal.dealOfferId;
    offer = [ttDealOffer getDealOffer:doId
                             customer:[CustomerHelper getLoggedInUser]
                              context:[CustomerHelper getContext]
                                error:&error];
    
    // double check the facebook session
    if (![FBSession activeSession].isOpen && [[CustomerHelper getLoggedInUser] isFacebookUser])
    {
        [FacebookHelper reopenSession];
    }
    
    // Define the layout for the deal
    dealLayout = [[DefaultDealLayoutState alloc] initWithDeal:deal offer:offer actionDelegate:self];

}

- (void)addBarCode
{
    
    // Add the bar code
    //
    /* ZXing testing notes...
     
     codes to test: PBFC, PB12SS, PB10AD, ET1309251996
     
     formats to test (kinda work, but don't look right):
     kBarcodeFormatCode128
     kBarcodeFormatCode39
     kBarcodeFormatITF
     
     formats that fail with "no encoder" message:
     kBarcodeFormatCode93
     kBarcodeFormatMaxiCode
     kBarcodeFormatRSS14
     kBarcodeFormatRSSExpanded
     kBarcodeFormatUPCE
     kBarcodeFormatUPCEANExtension
     
     formats that don't seem valid for these codes:
     kBarcodeFormatCodabar - Must start with ABCD?
     kBarcodeFormatEan13 - Must be 13 digits
     kBarcodeFormatEan8 - Must be 8 digits
     kBarcodeFormatUPCA - Must be 11 or 12 digits, but didn't work for ET1309251996 (checksum error)
     
     formats that are somewhere between a bar code and a qr-code:
     kBarcodeFormatPDF417
     
     formats that are QR-like:
     kBarcodeFormatAztec
     kBarcodeFormatQRCode
     kBarcodeFormatDataMatrix
     */
    
    /*
    ZXMultiFormatWriter* writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix* result = [writer encode:@"ET1309251996"
                                  format:kBarcodeFormatCode39
                                   width:self.qrCode.frame.size.width
                                  height:self.qrCode.frame.size.height
                                   error:nil];
    // TODO conditionally add a barcode
    if (result && NO) {
        self.qrCode.image = [UIImage imageWithCGImage:[ZXImage imageWithMatrix:result].cgimage];
    } else {
        self.qrCode.image = nil;
        self.qrCode.hidden = YES;
    }
     */
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return 1;
    }
    else
    {
        return [dealLayout tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeroImageCell" forIndexPath:indexPath];
        [(HeroImageCell *)cell setImageUrl:deal.deal.imageUrl];
    }
    else
    {
        cell = [dealLayout tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        return ROW_HEIGHT_HERO;
    }
    else
    {
        return [dealLayout tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section==0) ? 0.0:75.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section==0)
    {
        return nil;
    }
    else
    {
        [actionBar3View updateView:deal];
        return actionBar3View;
    }
}

#pragma mark -
#pragma mark - TaloolDealActionDelegate methods

- (void)sendGiftViaEmail:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)sendGiftViaFacebook:(id)sender
{
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)dealRedeemed:(id)sender
{
    UIAlertView *confirmView = [[UIAlertView alloc] initWithTitle:@"Please Confirm"
                                                          message:@"Would you like to redeem this deal?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
	[confirmView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        NSError *err = [NSError alloc];
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        [self.deal setCustomer:customer];
        [self.deal redeemHere:_customerLocation.coordinate.latitude
                    longitude:_customerLocation.coordinate.longitude
                        error:&err
                      context:[CustomerHelper getContext]];
        
        if (!err.code) {
            // Post the FB redeem action
            [FacebookHelper postOGRedeemAction:(ttDeal *)deal.deal atLocation:[deal.deal.merchant getClosestLocation]];
            // update the table view
            [actionBar3View updateView:deal];
            [self.tableView reloadData];
        }
        else if (err.code == -1009)
        {
            [CustomerHelper showNetworkError];
        }
        else
        {
            // show an error
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                                message:@"We failed to redeem this deal."
                                                               delegate:self
                                                      cancelButtonTitle:@"Please Try Again"
                                                      otherButtonTitles:nil];
            [errorView show];
        }
    }
}

#pragma mark - FBFriendPickerDelegate delegate methods

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend picked: %@, %@", user.name, [user objectForKey:@"id"]);
        [self handleFacebookUser:[user objectForKey:@"id"] name:user.name];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    // clean up, if needed
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *) getEmailFromContact:(ABRecordRef)person identifier:(ABMultiValueIdentifier)idx
{
    NSString *email;
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(multi) > 0)
    {
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multi, idx);
        email = (__bridge NSString *)(emailRef);
    }
    return email;
}

#pragma mark - Facebook helpers

- (void)handleFacebookUser:(NSString *)facebookId name:(NSString *)name
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSString *giftId = [customer giftToFacebook:deal.dealAcquireId
                                     facebookId:facebookId
                                 receipientName:name
                                          error:&error];
    if (!error.code)
    {
        [self announceShare:facebookId giftId:giftId];
        //[self sendFacebookAppRequest:facebookId giftId:giftId];
        [self confirmGiftSent:nil name:name];
    }
    else if (error.code == -1009)
    {
        [CustomerHelper showNetworkError];
    }
    else
    {
        [self displayError:error];
    }
}

- (void) displayError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                        message:@"We failed to send this gift."
                                                       delegate:self
                                              cancelButtonTitle:@"Please Try Again"
                                              otherButtonTitles:nil];
    [errorView show];
}

- (void) sendFacebookAppRequest:(NSString *)facebookId giftId:(NSString *)giftId
{
    friendCache = [[FBFrictionlessRecipientCache alloc] init];
    [friendCache prefetchAndCacheForSession:nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:@{
                        @"giftId": giftId}
                        options:0
                        error:&error];
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
        return;
    }
    NSString *giftStr = [[NSString alloc]
                         initWithData:jsonData
                         encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     facebookId, @"to",
                                     giftStr, @"data",
                                     nil];
    
    ttDeal *d = (ttDeal *)deal.deal;
    NSString *message = [NSString stringWithFormat:@"I thought you might like this deal!  %@", d.title];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:message
                                                    title:@"Send an Additional Private Message"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}
                                              friendCache:friendCache
     ];
    
    
    
}

/*
 
 THIS WOULD REACH USERS WHO DIDN'T CONNECT WITH FB, BUT HAVE THE FB APP INSTALLED
 
 - (IBAction)openFBPickerActionInShareDialog:(id)sender
 {
 // First create the Open Graph deal object for the deal being shared.
 ttDeal *deal = (ttDeal *)dealAcquire.deal;
 id<OGDeal> dealObject = [FacebookHelper dealObjectForDeal:deal];
 
 // Now create an Open Graph share action with the deal,
 id<OGShareDealAction> action = (id<OGShareDealAction>)[FBGraphObject graphObject];
 action.deal = dealObject;
 
 [FBDialogs presentShareDialogWithOpenGraphAction:action
 actionType:@"taloolclient:share"
 previewPropertyName:@"deal"
 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
 if(error) {
 NSLog(@"Error: %@", error.description);
 } else {
 NSLog(@"Success!");
 }
 }];
 }
 */

#pragma mark - Facebook Open Graph helpers

- (void)confirmGiftSent:(NSString *)email name:(NSString *)name
{
    // change the status of the deal
    ttFriend *friend = [ttFriend initWithName:name email:email context:[CustomerHelper getContext]];
    [deal setSharedWith:friend];
    [actionBar3View updateView:deal];
    [self.tableView reloadData];
}

- (void)announceShare:(NSString *)facebookId giftId:(NSString *)giftId
{
    if ([FBSession.activeSession isOpen])
    {
        if ([FBSession.activeSession.permissions
             indexOfObject:@"publish_actions"] == NSNotFound) {
            
            [FBSession.activeSession
             requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error) {
                     // re-call assuming we now have the permission
                     [self announceShare:facebookId giftId:giftId];
                 }
             }];
        } else {
            [FacebookHelper postOGShareAction:giftId toFacebookId:facebookId atLocation:[deal.deal.merchant getClosestLocation]];
        }
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate delegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
    /*
     NSString *name = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
     NSString *email;
     ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
     BOOL continueToProperties;
     
     if (ABMultiValueGetCount(multi)==0)
     {
     // Can we prevent users from selecting contacts without emails?
     NSLog(@"Contact picked with no emails: %@", name);
     // TODO alert user
     // let the user see there is no email address for this contact
     continueToProperties = YES;
     
     }
     else if (ABMultiValueGetCount(multi)==1)
     {
     email = [self getEmailFromContact:person identifier:0];
     NSLog(@"Contact picked: %@, %@", name, email);
     continueToProperties = NO;
     [self dismissViewControllerAnimated:YES completion:nil];
     [self handleUserContact:email name:name];
     }
     else
     {
     // let the user pick the right email from the contact properties
     continueToProperties = YES;
     }
     return continueToProperties;
     */
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonEmailProperty)
    {
        NSString *name = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *email = [self getEmailFromContact:person identifier:identifier];
        NSLog(@"Email picked: %@", email);
        [self dismissViewControllerAnimated:YES completion:nil];
        [self handleUserContact:email name:name];
    }
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Contacts (Address Book) helpers

- (void)handleUserContact:(NSString *)email name:(NSString *)name
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSString *giftId = [customer giftToEmail:deal.dealAcquireId
                                       email:email
                              receipientName:name
                                       error:&error];
    if (!error.code)
    {
        [self announceShare:nil giftId:giftId];
        [self confirmGiftSent:email name:name];
    }
    else if (error.code == -1009)
    {
        [CustomerHelper showNetworkError];
    }
    else
    {
        [self displayError:error];
    }
    
}

@end
