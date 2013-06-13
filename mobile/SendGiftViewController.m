//
//  SendGiftViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SendGiftViewController.h"
#import "DealRedemptionViewController.h"
#import "TaloolColor.h"
#import "FacebookHelper.h"
#import "FontAwesomeKit.h"
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "TaloolIconButton.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"

@interface SendGiftViewController ()

@end

@implementation SendGiftViewController

@synthesize friendPickerController, dealAcquire, friendCache;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // set the bgcolor and gift image and deal summary
    [self.view setBackgroundColor:[TaloolColor gray_2]];
    NSDictionary *attr =@{
                          FAKImageAttributeForegroundColor:[UIColor whiteColor],
                          FAKImageAttributeBackgroundColor:[UIColor colorWithPatternImage:[CategoryHelper getCircleWithColor:[TaloolColor orange] diameter:150]]
                          };
    
    giftImage.image =  [FontAwesomeKit imageForIcon:FAKIconGift
                              imageSize:CGSizeMake(150, 150)
                               fontSize:100
                             attributes:attr];
    
    dealTitle.text = dealAcquire.deal.title;
    
    attr =@{ FAKImageAttributeForegroundColor:[UIColor whiteColor] };
    UIImage *fbIcon = [FontAwesomeKit imageForIcon:FAKIconFacebook
                                                         imageSize:CGSizeMake(44, 44)
                                                          fontSize:36
                                                        attributes:attr];
    [facebookButton useTaloolStyle];
    [facebookButton setImage:fbIcon forState:UIControlStateNormal];
    [facebookButton setTitle:@"Pick a Facebook Friend" forState:UIControlStateNormal];
    [facebookButton setBaseColor:[TaloolColor teal]];
    
    // hide the FB button if there is no active session
    if (!FBSession.activeSession.isOpen)
    {
        [facebookButton setHidden:YES];
    }
    
    UIImage *userIcon = [FontAwesomeKit imageForIcon:FAKIconUser
                                                         imageSize:CGSizeMake(44, 44)
                                                          fontSize:36
                                                        attributes:attr];
    [contactButton useTaloolStyle];
    [contactButton setTitle:@"Pick a Contact Email" forState:UIControlStateNormal];
    [contactButton setImage:userIcon forState:UIControlStateNormal];
    [contactButton setBaseColor:[TaloolColor teal]];

}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = @"Share";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleFacebookUser:(NSString *)facebookId name:(NSString *)name
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSString *giftId = [customer giftToFacebook:dealAcquire.dealAcquireId
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
    
    ttDeal *deal = (ttDeal *)dealAcquire.deal;
    NSString *message = [NSString stringWithFormat:@"I thought you might like this deal!  %@", deal.title];
    
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

- (void)handleUserContact:(NSString *)email name:(NSString *)name
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSString *giftId = [customer giftToEmail:dealAcquire.dealAcquireId
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

- (void)confirmGiftSent:(NSString *)email name:(NSString *)name
{
    // change the status of the deal
    ttFriend *friend = [ttFriend initWithName:name email:email context:[CustomerHelper getContext]];
    [dealAcquire setSharedWith:friend];
    
    // go back to the deal
    [self.navigationController popViewControllerAnimated:YES];
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
            [FacebookHelper postOGShareAction:giftId toFacebookId:facebookId atLocation:dealAcquire.deal.merchant.location];
        }
    }
}

- (IBAction)openContactPickerAction:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
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

- (IBAction)openFBPickerAction:(id)sender
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

- (void) displayError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                        message:@"We failed to send this gift."
                                                       delegate:self
                                              cancelButtonTitle:@"Please Try Again"
                                              otherButtonTitles:nil];
    [errorView show];
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


@end
