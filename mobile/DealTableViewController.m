//
//  DealTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealTableViewController.h"
#import <MerchantLocationViewController.h>
#import "PersonViewController.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import <LocationHelper.h>
#import "DealActionBar3View.h"
#import "BarCodeCell.h"
#import "DealDetailCell.h"
#import "DealLayoutState.h"
#import "DefaultDealLayoutState.h"
#import <OperationQueueManager.h>
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import <CoreLocation/CoreLocation.h>
//#import "ZXingObjC/ZXingObjC.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Crashlytics/Crashlytics.h>


@interface DealTableViewController ()
@property (strong, nonatomic) MerchantLocationViewController *locationViewController;
@property (strong, nonatomic) ABPeoplePickerNavigationController *picker;
@end

@implementation DealTableViewController

@synthesize deal, offer, friendCache, dealLayout, actionBar3View;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    actionBar3View = [[DealActionBar3View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                                                          deal:deal
                                                      delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([deal isFault])
    {
        deal = (ttDealAcquire *)[CustomerHelper fetchFault:deal entityType:DEAL_ACQUIRE_ENTITY_NAME];
    }
    
    self.navigationItem.title = deal.deal.merchant.name;
    
    NSString *doId = deal.deal.dealOfferId;
    offer = [ttDealOffer fetchById:doId context:[CustomerHelper getContext]];
    
    // double check the facebook session
    if (![FBSession activeSession].isOpen && [[CustomerHelper getLoggedInUser] isFacebookUser])
    {
        [FacebookHelper reopenSession];
    }
    
    // Define the layout for the deal
    dealLayout = [[DefaultDealLayoutState alloc] initWithDeal:deal offer:offer actionDelegate:self];
    [self.tableView reloadData];
    
    [actionBar3View updateView:deal];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Deal Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

}

- (MerchantLocationViewController *) getLocationView
{
    if (!_locationViewController)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        _locationViewController = [storyboard instantiateViewControllerWithIdentifier:@"MerchantLocationView"];
    }
    [_locationViewController setMerchant:deal.deal.merchant];
    return _locationViewController;
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1)
    {
        [self.navigationController pushViewController:[self getLocationView] animated:YES];
    }
    
}


#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) giftSendOperationComplete:(NSDictionary *)response
{
    [SVProgressHUD dismiss];
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        NSManagedObjectContext *context = [CustomerHelper getContext];
        [context refreshObject:deal mergeChanges:YES];
        [actionBar3View updateView:deal];
        [self.tableView reloadData];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        // show an error
        [CustomerHelper showAlertMessage:error.localizedDescription
                               withTitle:@"Failed to Send Gift"
                              withCancel:@"Please Try Again"
                              withSender:self];
        
        
    }
    
}

- (void) redeemOperationComplete:(NSDictionary *)response
{
    [SVProgressHUD dismiss];
    NSNumber *success = [response objectForKey:@"success"];
    if ([success boolValue])
    {
        NSManagedObjectContext *context = [CustomerHelper getContext];
        [context refreshObject:deal mergeChanges:YES];
        [actionBar3View updateView:deal];
        [self.tableView reloadData];
    }
    else
    {
        NSError *error = [response objectForKey:@"error"];
        [CustomerHelper showAlertMessage:error.localizedDescription
                               withTitle:@"Failed to Redeem Deal"
                              withCancel:@"Please Try Again"
                              withSender:self];
    }
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
    if (!_picker)
    {
        _picker = [[ABPeoplePickerNavigationController alloc] init];
        [_picker setPeoplePickerDelegate:self];
    }
    [_picker popToRootViewControllerAnimated:NO];
    [self presentViewController:_picker animated:YES completion:nil];
    
}

- (void)sendGiftViaFacebook:(id)sender
{
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick A Friend";
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self.navigationController pushViewController:self.friendPickerController animated:YES];
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
        [SVProgressHUD showWithStatus:@"Redeeming deal" maskType:SVProgressHUDMaskTypeBlack];
        [[OperationQueueManager sharedInstance] startRedeemOperation:deal.dealAcquireId delegate:self];
    }
}


#pragma mark -
#pragma mark - FBFriendPickerDelegate delegate methods

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        [self handleFacebookUser:[user objectForKey:@"id"] name:user.name];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    // clean up, if needed
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Facebook helpers

- (void)handleFacebookUser:(NSString *)facebookId name:(NSString *)name
{
    [SVProgressHUD showWithStatus:@"Sending gift" maskType:SVProgressHUDMaskTypeBlack];
    [[OperationQueueManager sharedInstance] startFacebookGiftOperation:facebookId
                                                         dealAcquireId:deal.dealAcquireId
                                                         recipientName:name
                                                              delegate:self];
}

// THIS REACHES USERS WHO DIDN'T CONNECT WITH FB, BUT HAVE THE FB APP INSTALLED
// let the user write their own message, so it shows up on the timeline (explicit share)
// This would give us great placement on the timeline and notify the user
// but if the user cancels the post, the gift would be orphaned.
- (void)openFBPickerActionInShareDialog:(id)sender facebookId:(NSString *)facebookId name:(NSString *)name giftId:(NSString *)giftId
 {
     // First create the Open Graph deal object for the deal being shared.
     //id<OGDeal> dealObject = [FacebookHelper dealObjectForDeal:deal.deal];
     id<OGDeal> dealObject = [FacebookHelper dealObjectForGift:giftId];
 
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

#pragma mark -
#pragma mark - ABPeoplePickerNavigationControllerDelegate delegate methods for iOS8

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [self confirmPerson:person];
}

#pragma mark -
#pragma mark - ABPeoplePickerNavigationControllerDelegate delegate methods for iOS7

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self confirmPerson:person];
    
    // return no, so we get out of the shitty address book views
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark - People Picker Helpers

- (void) confirmPerson:(ABRecordRef)person
{
    // store person properties in a dictionay, so we don't have to deal the Address Book crap
    NSMutableDictionary *personDictionary = [[NSMutableDictionary alloc] init];
    
    // load the person's name in the dictionary
    NSString *fname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (!fname) fname=@"";
    if (!lname) lname=@"";
    [personDictionary setObject:fname forKey:[NSNumber numberWithInt:kABPersonFirstNameProperty]];
    [personDictionary setObject:lname forKey:[NSNumber numberWithInt:kABPersonLastNameProperty]];
    
    // load the person's emails in the dictionary
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    NSMutableDictionary *email;
    NSString *emailLabel, *emailAddress;
    CFArrayRef linked = ABPersonCopyArrayOfAllLinkedPeople(person);
    ABRecordRef iLinkedPerson;
    ABMutableMultiValueRef abEmails;
    NSInteger count = CFArrayGetCount(linked);
    for (CFIndex m = 0; m < count; m++) {
        iLinkedPerson = CFArrayGetValueAtIndex(linked, m);
        abEmails = ABRecordCopyValue(iLinkedPerson, kABPersonEmailProperty);
        
        for (int i=0; i<ABMultiValueGetCount(abEmails); i++)
        {
            emailLabel = (__bridge NSString*) ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(abEmails, i));
            emailAddress = (__bridge NSString *)ABMultiValueCopyValueAtIndex(abEmails, i);
            
            if (!emailLabel) emailLabel=@"";
            if (emailAddress)
            {
                email = [[NSMutableDictionary alloc] init];
                [email setObject:emailLabel forKey:KEY_EMAIL_LABEL];
                [email setObject:emailAddress forKey:KEY_EMAIL_ADDRESS];
                [emails addObject:email];
            }
            
        }
    }
    if (linked) CFRelease(linked);
    [personDictionary setObject:emails forKey:[NSNumber numberWithInt:kABPersonEmailProperty]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        // push the person view to confirm the email selection
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        PersonViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"PersonView"];
        [pvc setDelegate:self];
        [pvc setPerson:personDictionary];
        [self.navigationController pushViewController:pvc animated:YES];
    }];
}


#pragma mark -
#pragma mark - PersonViewDelegate methods

- (void)handleUserContact:(NSString *)email name:(NSString *)name
{
    [self.navigationController popViewControllerAnimated:YES];
    
    // send the gift
    [SVProgressHUD showWithStatus:@"Sending gift" maskType:SVProgressHUDMaskTypeBlack];
    [[OperationQueueManager sharedInstance] startEmailGiftOperation:email
                                                      dealAcquireId:deal.dealAcquireId
                                                      recipientName:name
                                                           delegate:self];
}



@end
