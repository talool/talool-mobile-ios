//
//  TaloolDealViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolDealViewController.h"
#import "TaloolDealActionViewController.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "CategoryHelper.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttFriend.h"
#import "ZXingObjC/ZXingObjC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TaloolDealViewController ()

@end

@implementation TaloolDealViewController

@synthesize qrCode, deal, friendPickerController, friendCache, texture;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:self.view.frame.size];
    [self.texture setAlpha:0.15];
}
- (IBAction)swipeAction:(id)sender
{
    if ([deal hasBeenRedeemed] || [deal hasBeenShared] || [deal hasExpired])
    {
        return;
    }

    TaloolDealActionViewController *dealActionView = [self.storyboard instantiateViewControllerWithIdentifier:@"DealActionView"];
    dealActionView.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    dealActionView.deal = self.deal;
    dealActionView.dealActionDelegate = self;
    [self presentViewController:dealActionView animated:YES completion:nil];
    [self.pageCurl setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = deal.deal.merchant.name;
    self.titleLabel.text = self.deal.deal.title;
    self.summaryLabel.text = self.deal.deal.summary;
    self.detailsLabel.text = self.deal.deal.details;
    
    // Here we use the new provided setImageWithURL: method to load the web image
    [self.prettyPicture setImageWithURL:[NSURL URLWithString:self.deal.deal.imageUrl]
                       placeholderImage:[UIImage imageNamed:@"000.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                  }
                                  
                              }];
    
    // TODO get the closest location... test this
    ttMerchant *merch = (ttMerchant *)self.deal.deal.merchant;
    ttMerchantLocation *ml = [merch getClosestLocation:0.0 longitude:0.0];
    [self.merchantLogo setImageWithURL:[NSURL URLWithString:ml.logoUrl]
                      placeholderImage:[UIImage imageNamed:@"000.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 if (error !=  nil) {
                                     // TODO track these errors
                                     NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                 }
                                 
                             }];
    NSError *error;
    NSString *doId = deal.deal.dealOfferId;
    ttDealOffer *offer = [ttDealOffer getDealOffer:doId
                                          customer:[CustomerHelper getLoggedInUser]
                                           context:[CustomerHelper getContext]
                                             error:&error];
    [self.offerLogo setImageWithURL:[NSURL URLWithString:offer.imageUrl]
                   placeholderImage:[UIImage imageNamed:@"000.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                              }
                          }];
    
    if ([self.deal hasBeenRedeemed])
    {
        [self markAsRedeemed];
    }
    else if ([self.deal hasBeenShared])
    {
        [self markAsShared];
    }
    else
    {
        
        [self addBarCode];
        self.redemptionCode.hidden = YES;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString *exp;
        if (self.deal.deal.expires == nil)
        {
            exp = @"Never Expires";
        }
        else
        {
            exp = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:self.deal.deal.expires]];
        }
        self.expiresLabel.text = exp;
    }
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
}


- (void)markAsRedeemed
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    self.expiresLabel.text = [NSString stringWithFormat:@"Redeemed on %@.",
                              [dateFormatter stringFromDate:self.deal.redeemed]];
    
    if (self.deal.redemptionCode !=nil)
    {
        self.redemptionCode.text = self.deal.redemptionCode;
        self.redemptionCode.hidden = NO;
    }
    else
    {
        self.redemptionCode.hidden = YES;
    }
    
    self.instructionsLabel.hidden = YES;
    
    [self updateTextColor:[TaloolColor gray_4]];
    [self.view setBackgroundColor:[TaloolColor gray_1]];
    [self.pageCurl setHidden:YES];
}

- (void)markAsShared
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *shareLabel;
    if (self.deal.shared == nil)
    {
        shareLabel = @"shared with a friend";
    }
    else
    {
        shareLabel = [NSString stringWithFormat:@"Shared on %@", [dateFormatter stringFromDate:self.deal.shared]];
    }
    self.expiresLabel.text = shareLabel;
    
    self.instructionsLabel.hidden = YES;
    
    [self updateTextColor:[TaloolColor gray_4]];
    [self.view setBackgroundColor:[TaloolColor gray_1]];
    
    ttFriend *friend = self.deal.sharedTo;
    if (friend == nil)
    {
        self.redemptionCode.hidden = YES;
    }
    else
    {
        NSString *friendLabel;
        if (friend.email == nil)
        {
            friendLabel = [NSString stringWithFormat:@"Shared to %@", friend.fullName];
        }
        else
        {
            friendLabel = [NSString stringWithFormat:@"Shared to %@", friend.email];
        }
        self.redemptionCode.text = friendLabel;
        self.redemptionCode.hidden = NO;
    }
    [self.pageCurl setHidden:YES];
}

-(void)updateTextColor:(UIColor *)color
{
    self.titleLabel.textColor = color;
    self.summaryLabel.textColor = color;
    self.detailsLabel.textColor = color;
    self.expiresLabel.textColor = color;
    self.redemptionCode.textColor = color;
}

-(void) reset:(ttDealAcquire *)newDeal
{
    self.deal = newDeal;
    if ([self.deal hasBeenRedeemed])
    {
        [self markAsRedeemed];
    }
    else if ([self.deal hasBeenRedeemed])
    {
        [self markAsShared];
    }
}

#pragma mark - TaloolDealActionDelegate delegate methods

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
    [self markAsRedeemed];
}

- (void)dealActionCanceled:(id)sender
{
    //[self.pageCurl setHidden:NO];
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
    if (error.code < 100)
    {
        [self announceShare:facebookId giftId:giftId];
        //[self sendFacebookAppRequest:facebookId giftId:giftId];
        [self confirmGiftSent:nil name:name];
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
    
    // TODO need to move this
    [self markAsShared];
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
            [FacebookHelper postOGShareAction:giftId toFacebookId:facebookId atLocation:deal.deal.merchant.location];
        }
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate delegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
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
    if (error.code < 100)
    {
        [self announceShare:nil giftId:giftId];
        [self confirmGiftSent:email name:name];
    }
    else
    {
        [self displayError:error];
    }
    
}


@end
