//
//  ResetPasswordViewController.m
//  Talool
//
//  Created by Douglas McCuen on 9/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "KeyboardAccessoryView.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "Talool-API/ttCustomer.h"
#import "CustomerHelper.h"
#import "TextureHelper.h"
#import "AppDelegate.h"
#import "TaloolTabBarController.h"
#import "MyDealsViewController.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

@synthesize spinner, customerId, resetCode;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    [changePasswordButton useTaloolStyle];
    [changePasswordButton setBaseColor:[TaloolColor teal]];
    [changePasswordButton setTitle:@"Change Password" forState:UIControlStateNormal];
    
    spinner.hidesWhenStopped=YES;
    
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Submit"];
    [passwordField setInputAccessoryView:kav];
    [confirmPasswordField setInputAccessoryView:kav];
    [passwordField setDelegate:self];
    [confirmPasswordField setDelegate:self];
    [passwordField setDefaultBorderColor];
    [confirmPasswordField setDefaultBorderColor];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Reset Password Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

- (IBAction)cancelAction:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changePasswordAction:(id) sender
{
    // add a spinner
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    if (passwordField.text == nil || confirmPasswordField.text == nil)
    {
        [CustomerHelper showErrorMessage:@"You must enter your new password twice."
                               withTitle:@"Password Error"
                              withCancel:@"Try Again"
                              withSender:nil];
    }
    else if (![passwordField.text isEqualToString:confirmPasswordField.text])
    {
        [CustomerHelper showErrorMessage:@"Your passwords don't match."
                               withTitle:@"Password Error"
                              withCancel:@"Try Again"
                              withSender:nil];
    }
    else
    {
        NSError *err;
        ttCustomer *customer = [ttCustomer resetPassword:customerId
                                                password:passwordField.text
                                                    code:resetCode
                                                 context:[CustomerHelper getContext]
                                                   error:&err];
        if (customer.token != nil)
        {
            [CustomerHelper handleNewLogin];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [CustomerHelper showErrorMessage:err.localizedDescription
                                   withTitle:@"Password Reset Failure"
                                  withCancel:@"Ok"
                                  withSender:nil];
        }
        
    }
    
    // remove the spinner
    [spinner stopAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [self changePasswordAction:self];
    
}
-(void) cancel:(id)sender
{
    if ([passwordField isFirstResponder])
    {
        [passwordField resignFirstResponder];
    }
    else
    {
        [confirmPasswordField resignFirstResponder];
    }
    
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}

@end
