//
//  RegistrationViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RegistrationViewController.h"
#import "CustomerController.h"
#import "Customer.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize errorView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"userRegistered"]) {
        /* probably unneeded... we'll hook to the save button and save off the user there.
         The customerController will be able to pull the logged in user from a data store.
        */
        //[[segue destinationViewController] setCustomer:customer];
    } else if ([[segue identifier] isEqualToString:@"registrationError"]) {
        // cook up the error message and pass the error object to the error view
    }
}

- (IBAction)onRegistration:(id)sender
{
    Customer *customer = [[Customer alloc] init];
    customer.name = emailField.text;
    customer.password = passwordField.text;
    
    // TODO: check the response object and display errors as needed
    CustomerController *cController = [[CustomerController alloc] init];
    BOOL isRegistrationComplete = [cController registerUser:customer];
    
    if (isRegistrationComplete) {
        [self performSegueWithIdentifier:@"userRegistered" sender:sender];
    } else {
        NSString *message = @"Fail!  Please enter the right data.";
        [self showErrorMessage:message withTitle:@"yo!"];
    }
}

- (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title
{
	self.errorView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"try again" otherButtonTitles:nil];
	[self.errorView show];
}

@end
