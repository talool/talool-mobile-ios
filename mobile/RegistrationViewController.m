//
//  RegistrationViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

// TODO: enable/disable the button based on ttCustomer.isValid
#import "AppDelegate.h"
#import "RegistrationViewController.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "KeyboardAccessoryView.h"
#import "talool-api-ios/GAI.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize errorView, spinner;

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
    
    [emailField setDefaultBorderColor];
    [passwordField setDefaultBorderColor];
    [firstNameField setDefaultBorderColor];
    [lastNameField setDefaultBorderColor];
    
    spinner.hidesWhenStopped = YES;
    
    [regButton useTaloolStyle];
    [regButton setBaseColor:[TaloolColor teal]];
    [regButton setTitle:@"Register" forState:UIControlStateNormal];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Registration Screen"];
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSNumber *sex = [[NSNumber alloc] initWithInt:1]; // TODO ask the user for this
    
    ttCustomer *user = [ttCustomer createCustomer:firstNameField.text
                                         lastName:lastNameField.text
                                            email:emailField.text
                                              sex:sex
                                    socialAccount:nil
                                          context:appDelegate.managedObjectContext];
    
    // Register the user.  The Helper will display errors.
    // don't leave the page if reg failed
    if ([CustomerHelper registerCustomer:user password:passwordField.text] && [CustomerHelper getLoggedInUser]!=nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [spinner stopAnimating];
    
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

- (IBAction)regAction:(id)sender {
    [self submit:sender];
}

@end
