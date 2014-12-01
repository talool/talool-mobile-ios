//
//  LoginViewController.m
//  Talool
//
//  Created by Douglas McCuen on 9/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CustomerHelper.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "Talool-API/ttCustomer.h"
#import "KeyboardAccessoryView.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "TextureHelper.h"
#import "OperationQueueManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    [signinButton useTaloolStyle];
    [signinButton setBaseColor:[TaloolColor teal]];
    [signinButton setTitle:@"Log In" forState:UIControlStateNormal];
    
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Log In"];
    [emailField setInputAccessoryView:kav];
    [passwordField setInputAccessoryView:kav];
    [passwordField setDelegate:self];
    [emailField setDelegate:self];
    
    [emailField setDefaultBorderColor];
    [passwordField setDefaultBorderColor];
    
    [forgotButton setTitleColor:[TaloolColor dark_teal] forState:UIControlStateNormal];

}

- (void)viewWillAppear:(BOOL)animated
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate switchToMainView];
    }
}

- (IBAction)loginAction:(id) sender
{
    [SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeBlack];
    
    [[OperationQueueManager sharedInstance] authUser:emailField.text password:passwordField.text delegate:self];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [self loginAction:self];
    
}
-(void) cancel:(id)sender
{
    if ([emailField isFirstResponder])
    {
        [emailField resignFirstResponder];
    }
    else
    {
        [passwordField resignFirstResponder];
    }
    
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}

#pragma mark -
#pragma mark - OperationQueueDelegate delegate

- (void)userAuthComplete:(NSDictionary *)response
{
    // remove the spinner
    [SVProgressHUD dismiss];
    
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate switchToMainView];
        
        [[OperationQueueManager sharedInstance] handleForegroundState];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        
        // TODO the error coming straight from the service may not be as "clean" as we'd like...
        // condsider using a hard coded string and logging the failture (it's logged already)
        [CustomerHelper showAlertMessage:error.localizedDescription
                               withTitle:@"Authentication Failed"
                              withCancel:@"Try again"
                              withSender:nil];
    }

}

@end
