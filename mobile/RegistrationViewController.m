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
#import "talool-api-ios/CustomerController.h"
#import "CustomerHelper.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize errorView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: make sure we're logged out

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRegistration:(id)sender
{
    NSNumber *sex = [[NSNumber alloc] initWithInt:1]; // TODO ask the user for this
    
    ttCustomer *user = [CustomerHelper createCustomer:firstNameField.text
                                             lastName:lastNameField.text
                                                email:emailField.text
                                             password:passwordField.text
                                                  sex:sex
                                              socialAccount:nil];
    
    // Register the user.  Check the response and display errors as needed
    [CustomerHelper registerCustomer:user sender:self];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
}

@end
