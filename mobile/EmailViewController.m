//
//  EmailViewController.m
//  Talool
//
//  Created by Douglas McCuen on 10/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "EmailViewController.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "KeyboardAccessoryView.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "Talool-API/ttCustomer.h"
#import "CustomerHelper.h"

@interface EmailViewController ()

@end

@implementation EmailViewController

@synthesize customer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];
    
    [saveButton useTaloolStyle];
    [saveButton setBaseColor:[TaloolColor teal]];
    [saveButton setTitle:@"Complete Registration" forState:UIControlStateNormal];
    
    spinner.hidesWhenStopped=YES;
    
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Submit"];
    [emailField setInputAccessoryView:kav];
    [emailField setDelegate:self];
    [emailField setDefaultBorderColor];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Save Email Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (IBAction)saveAction:(id) sender
{
    
    
    if (emailField.text == nil || [emailField.text isEqualToString:@""])
    {
        [CustomerHelper showErrorMessage:@"You must enter your email address to complete registration."
                               withTitle:@"Oops!"
                              withCancel:@"Try Again"
                              withSender:nil];
    }
    else if (![CustomerHelper isEmailValid:emailField.text])
    {
        [CustomerHelper showErrorMessage:@"You must enter a valid email address to complete registration."
                               withTitle:@"Email Error"
                              withCancel:@"Try Again"
                              withSender:nil];
    }
    else
    {
        // add a spinner
        [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
#warning "EmailView needs to be retired"
        /*
        NSError *err;
        [customer setEmail:emailField.text];

        if ([CustomerHelper registerCustomer:customer password:[ttCustomer nonrandomPassword:emailField.text]])
        {
            [CustomerHelper handleNewLogin];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];

        }
        else
        {
            [CustomerHelper showErrorMessage:err.localizedDescription
                                   withTitle:@"Registration Failure"
                                  withCancel:@"Ok"
                                  withSender:nil];
        }
        */
        // remove the spinner
        [spinner stopAnimating];
        
    }
}

- (IBAction)cancelAction:(id) sender
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [self saveAction:self];
    
}
-(void) cancel:(id)sender
{
    if ([emailField isFirstResponder])
    {
        [emailField resignFirstResponder];
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
