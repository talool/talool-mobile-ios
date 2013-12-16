//
//  RegistrationViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

// TODO: enable/disable the button based on ttCustomer.isValid
#import "RegistrationViewController.h"
#import "CustomerHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttSocialAccount.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "KeyboardAccessoryView.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "OperationQueueManager.h"

#define sexUndefinedIndex   0
#define sexFemaleIndex      1
#define sexMaleIndex        2
#define tableRowHeader      0
#define tableRowBirthDate   4
#define tableRowSubmit      8
#define rowHeightDefault    40
#define rowHeightPicker     200
#define rowHeightHeader     50
#define rowHeightSubmit     90

@interface RegistrationViewController ()
@property (nonatomic, retain) NSIndexPath *datePickerIndexPath;
@property (assign) BOOL datePickerOpen;
@property (nonatomic, retain) NSDateFormatter *formatter;
@end

@implementation RegistrationViewController

@synthesize errorView, spinner, failedUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Registration"];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Register"];
    [emailField setInputAccessoryView:kav];
    [emailField setDelegate:self];
    [passwordField setInputAccessoryView:kav];
    [passwordField setDelegate:self];
    [firstNameField setInputAccessoryView:kav];
    [firstNameField setDelegate:self];
    [lastNameField setInputAccessoryView:kav];
    [lastNameField setDelegate:self];
    [birthDateField setInputAccessoryView:kav];
    [birthDateField setDelegate:self];
    
    [emailField setDefaultBorderColor];
    [passwordField setDefaultBorderColor];
    [firstNameField setDefaultBorderColor];
    [lastNameField setDefaultBorderColor];
    [birthDateField setDefaultBorderColor];
    
    spinner.hidesWhenStopped = YES;
    
    [regButton useTaloolStyle];
    [regButton setBaseColor:[TaloolColor teal]];
    [regButton setTitle:@"Register" forState:UIControlStateNormal];
    
    self.datePickerIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    self.datePickerOpen = NO;
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MM/dd/YYYY"];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (failedUser)
    {
        // preload the form
        emailField.text = failedUser.email;
        firstNameField.text = failedUser.firstName;
        lastNameField.text = failedUser.lastName;
        if (failedUser.birthDate)
        {
            birthDateField.text = [self.formatter stringFromDate:failedUser.birthDate];
        }
        sexPicker.selectedSegmentIndex = [failedUser.sex intValue];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Registration Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    NSNumber *sex = [NSNumber numberWithInt:[sexPicker selectedSegmentIndex]];
    
    NSDate *bday = nil;
    if (birthDateField.text)
    {
        bday = [datePicker date];
    }
    
    NSString *facebookId;
    NSString *facebookToken;
    if (failedUser)
    {
        ttSocialAccount *sa = [[failedUser.socialAccounts objectEnumerator] nextObject];
        if (sa)
        {
            facebookId = sa.loginId;
            facebookToken = [[[FBSession activeSession] accessTokenData] accessToken];
        }
    }
    
    // Register the user.  The Helper will display errors.
    // don't leave the page if reg failed
    [[OperationQueueManager sharedInstance] regUser:emailField.text
                                           password:passwordField.text
                                          firstName:firstNameField.text
                                           lastName:lastNameField.text
                                                sex:sex
                                          birthDate:bday
                                         facebookId:facebookId
                                      facebookToken:facebookToken
                                           delegate:self];
    
}
-(void) cancel:(id)sender
{
    if ([emailField isFirstResponder])
    {
        [emailField resignFirstResponder];
    }
    else if ([passwordField isFirstResponder])
    {
        [passwordField resignFirstResponder];
    }
    else if ([firstNameField isFirstResponder])
    {
        [firstNameField resignFirstResponder];
    }
    else
    {
        [lastNameField resignFirstResponder];
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.datePickerOpen) [self dateAction:self];
}

#pragma mark -

- (IBAction)dateChanged:(id)sender
{
    birthDateField.text = [self.formatter stringFromDate:[datePicker date]];
}

- (IBAction)regAction:(id)sender {
    [self submit:sender];
}

- (IBAction)dateAction:(id)sender {

    self.datePickerOpen = !self.datePickerOpen;
    
    if (self.datePickerOpen) [self cancel:self];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.datePickerIndexPath] == NSOrderedSame)
    {
        if (self.datePickerOpen) return rowHeightPicker;
        else return 0;
    }
    else if (indexPath.row == tableRowHeader)
    {
        return rowHeightHeader;
    }
    else if (indexPath.row == tableRowSubmit)
    {
        return rowHeightSubmit;
    }
    return rowHeightDefault;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.datePickerIndexPath] != NSOrderedSame)
    {
        if (indexPath.row==tableRowBirthDate)
        {
            [self dateAction:self];
        }
    }
    return;
}


#pragma mark -
#pragma mark - OperationQueueDelegate delegate

- (void)userAuthComplete:(NSDictionary *)response
{
    // remove the spinner
    [spinner stopAnimating];
    
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        // show error message (CustomerHelper.loginFacebookUser doesn't handle this)
        [CustomerHelper showErrorMessage:error.localizedDescription
                               withTitle:@"Authentication Failed"
                              withCancel:@"Try again"
                              withSender:nil];
    }
}


@end
