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

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize errorView, spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];

    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Register"];
    [emailField setInputAccessoryView:kav];
    [passwordField setInputAccessoryView:kav];
    [firstNameField setInputAccessoryView:kav];
    [lastNameField setInputAccessoryView:kav];
    
    spinner.hidesWhenStopped = YES;
    
    texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:CGSizeMake(320.0, 1200.0)];
    [texture setAlpha:0.15];
    
    scroller.contentSize = CGSizeMake(self.view.frame.size.width, 1200.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerAuthDelegate:(id <TaloolAuthenticationDelegate>)delegate
{
    authDelegate = delegate;
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
    
    // Register the user.  Check the response and display errors as needed
    [CustomerHelper registerCustomer:user password:passwordField.text];
    
    // don't leave the page if reg failed
    if ([CustomerHelper getLoggedInUser] != nil) {
        [authDelegate customerLoggedIn:self];
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

-(void) previous:(id)sender
{
    
}

-(void) next:(id)sender
{
    
}

@end
