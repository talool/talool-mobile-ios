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
#import <OperationQueueManager.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "WhiteLabelHelper.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

@synthesize customerId, resetCode;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    [changePasswordButton useTaloolStyle];
    [changePasswordButton setBaseColor:[TaloolColor teal]];
    [changePasswordButton setTitle:@"Change Password" forState:UIControlStateNormal];
    
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Submit"];
    [passwordField setInputAccessoryView:kav];
    [confirmPasswordField setInputAccessoryView:kav];
    [passwordField setDelegate:self];
    [confirmPasswordField setDelegate:self];
    [passwordField setDefaultBorderColor];
    [confirmPasswordField setDefaultBorderColor];
    
    [cancleButton setTitleColor:[TaloolColor dark_teal] forState:UIControlStateNormal];
    
    [logo setImage:[UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"LogoAndIcon"]]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Reset Password Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changePasswordAction:(id) sender
{
    
    
    if (passwordField.text == nil || confirmPasswordField.text == nil)
    {
        [CustomerHelper showAlertMessage:@"You must enter your new password twice."
                               withTitle:@"Password Error"
                              withCancel:@"Try Again"
                              withSender:nil];
    }
    else if (![passwordField.text isEqualToString:confirmPasswordField.text])
    {
        [CustomerHelper showAlertMessage:@"Your passwords don't match."
                               withTitle:@"Password Error"
                              withCancel:@"Try Again"
                              withSender:nil];
    }
    else
    {
        // add a spinner
        [SVProgressHUD showWithStatus:@"Changing password" maskType:SVProgressHUDMaskTypeBlack];
        
        [[OperationQueueManager sharedInstance] startPasswordResetOperation:customerId
                                                                   password:passwordField.text
                                                                changeToken:resetCode
                                                                   delegate:self];
    }
    
    
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


#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) passwordResetOperationComplete:(NSDictionary *)response
{
    // remove the spinner
    [SVProgressHUD dismiss];
    
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        [[OperationQueueManager sharedInstance] handleForegroundState];
        [self dismissViewControllerAnimated:NO completion:nil];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.navigationController popToRootViewControllerAnimated:NO];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        [CustomerHelper showAlertMessage:error.localizedDescription
                               withTitle:@"Password Reset Failure"
                              withCancel:@"Ok"
                              withSender:nil];
    }
    
}

@end
