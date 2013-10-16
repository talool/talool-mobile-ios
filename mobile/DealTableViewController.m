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
#import "DealLayoutState.h"
#import "DefaultDealLayoutState.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import "ZXingObjC/ZXingObjC.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>


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
    actionBar3View = [[DealActionBar3View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Deal Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"])
    {
        [[segue destinationViewController] setMerchant:deal.deal.merchant];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dealLayout tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dealLayout tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dealLayout tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [actionBar3View updateView:deal];
    return actionBar3View;
}

#pragma mark -
#pragma mark - TaloolDealActionDelegate methods

- (void)sendGift:(id)sender
{
    if ([FBSession activeSession].isOpen || [[CustomerHelper getLoggedInUser] isFacebookUser])
    {
        // open action sheet
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to send this deal as a gift?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Send Gift via Facebook", @"Send Gift via Email", nil];

        [actionSheet showInView:self.view.window];
    }
    else
    {
        [self sendGiftViaEmail:sender];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) [self sendGiftViaFacebook:self];
    else if (buttonIndex == 1) [self sendGiftViaEmail:self];
}

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
    NSLog(@"Gift created: %@", giftId);
    
    if (!error.code)
    {
        // Post to FB
        [self openFBPickerActionInShareDialog:self facebookId:facebookId name:name];
        //[self announceShare:facebookId giftId:giftId];  // TODO find a way to do this if the user hits "cancel" in the share dialog

        // Update the view so it's clear that the deal was gifted
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

// THIS REACHES USERS WHO DIDN'T CONNECT WITH FB, BUT HAVE THE FB APP INSTALLED
// let the user write their own message, so it shows up on the timeline (explicit share)
// This would give us great placement on the timeline and notify the user
// but if the user cancels the post, the gift would be orphaned.
 - (void)openFBPickerActionInShareDialog:(id)sender facebookId:(NSString *)facebookId name:(NSString *)name
 {
     // First create the Open Graph deal object for the deal being shared.
     id<OGDeal> dealObject = [FacebookHelper dealObjectForDeal:deal.deal];
 
     // Now create an Open Graph share action with the deal,
     id<OGGiftDealAction> action = (id<OGGiftDealAction>)[FBGraphObject graphObject];
     action.deal = dealObject;
     
     [action setTags:@[facebookId]];
 
     [FBDialogs presentShareDialogWithOpenGraphAction:action
                                           actionType:@"taloolclient:gift"
                                  previewPropertyName:@"deal"
                                              handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                  if(error) {
                                                      NSLog(@"Error: %@", error.description);
                                                  } else {
                                                      NSLog(@"Success!");
                                                  }
                                              }];

}


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
            [FacebookHelper postOGGiftAction:giftId toFacebookId:facebookId atLocation:[deal.deal.merchant getClosestLocation]];
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
