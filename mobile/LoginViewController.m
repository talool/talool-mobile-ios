//
//  LoginViewController.m
//  Talool
//
//  Created by Douglas McCuen on 9/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomerHelper.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttCustomer.h"
#import "KeyboardAccessoryView.h"
#import "talool-api-ios/GAI.h"
#import "TextureHelper.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    [signinButton useTaloolStyle];
    [signinButton setBaseColor:[TaloolColor teal]];
    [signinButton setTitle:@"Sign In" forState:UIControlStateNormal];
    
    spinner.hidesWhenStopped=YES;
    
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Sign In"];
    [emailField setInputAccessoryView:kav];
    [passwordField setInputAccessoryView:kav];
    [passwordField setDelegate:self];
    [emailField setDelegate:self];
    
    [emailField setDefaultBorderColor];
    [passwordField setDefaultBorderColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Login Screen"];
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

- (IBAction)loginAction:(id) sender
{
    // add a spinner
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    // don't leave the page if login failed
    if ([CustomerHelper loginUser:emailField.text password:passwordField.text]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    // remove the spinner
    [spinner stopAnimating];
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

@end
