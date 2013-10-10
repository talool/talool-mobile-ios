//
//  SendPasswordResetViewController.m
//  Talool
//
//  Created by Douglas McCuen on 9/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SendPasswordResetViewController.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "KeyboardAccessoryView.h"
#import "talool-api-ios/GAI.h"
#import "talool-api-ios/ttCustomer.h"
#import "CustomerHelper.h"

@interface SendPasswordResetViewController ()

@end

@implementation SendPasswordResetViewController

@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    [sendEmailButton useTaloolStyle];
    [sendEmailButton setBaseColor:[TaloolColor teal]];
    [sendEmailButton setTitle:@"Request Password Change" forState:UIControlStateNormal];
    
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
    [tracker sendView:@"Send Password Reset Email Screen"];
    
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

- (IBAction)sendEmailAction:(id) sender
{
    // add a spinner
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    // make sure the email is valid before calling the service
    if (emailField.text != nil)
    {
        NSError *err;
        if ([ttCustomer sendResetPasswordEmail:emailField.text error:&err])
        {
            [CustomerHelper showErrorMessage:@"Please check your inbox shortly" withTitle:@"Email Sent" withCancel:@"Ok" withSender:nil];
            [emailField resignFirstResponder];
        }
        else
        {
            [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Email Failure" withCancel:@"Ok" withSender:nil];
        }
    }
    else
    {
        [CustomerHelper showErrorMessage:@"Please enter your email" withTitle:@"Email Failure" withCancel:@"Ok" withSender:nil];
    }
    
    // remove the spinner
    [spinner stopAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [self sendEmailAction:self];
    
}
-(void) cancel:(id)sender
{
    [emailField resignFirstResponder];
    
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}


@end
