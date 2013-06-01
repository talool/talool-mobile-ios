//
//  SendGiftViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SendGiftViewController.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"
#import "CategoryHelper.h"
#import "TaloolIconButton.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"

@interface SendGiftViewController ()

@end

@implementation SendGiftViewController

@synthesize friendPickerController, dealAcquire;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // TODO set the bgcolor and gift image and deal summary
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
    // TODO - call the service
    [self confirmGiftSent];
}

- (void)handleUserContact:(NSString *)email name:(NSString *)name
{
    // TODO - call the service
    [self confirmGiftSent];
}

- (void)confirmGiftSent
{
    // TODO - show alert and change text labels
}

- (IBAction)openContactPickerAction:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

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
    
    if (ABMultiValueGetCount(multi) == 0)
    {
        // Can we prevent users from selecting contacts without emails?
        NSLog(@"Contact picked with no emails: %@", name);
        // TODO alert user
        continueToProperties = NO;
        
    }
    else if (ABMultiValueGetCount(multi) == 1)
    {
        email = [self getEmailFromContact:person];
        NSLog(@"Contact picked: %@, %@", name, email);
        continueToProperties = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self handleUserContact:email name:name];
    }
    else
    {
        // how can the user pick from a list of emails
        // can we limit the properties that are displayed?
        continueToProperties = YES;
    }
    return continueToProperties;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonEmailProperty)
    {
        NSString *name = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *email = [self getEmailFromContact:person];
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

- (NSString *) getEmailFromContact:(ABRecordRef)person
{
    NSString *email;
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(multi) > 0) {
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multi, 0);
        email = (__bridge NSString *)(emailRef);
    }
    return email;
}


@end
