//
//  RegistrationViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

// TODO: enable/disable the button based on ttCustomer.isValid

#import "MasterNavigationController.h"
#import "RegistrationViewController.h"
#import "talool-api-ios/CustomerController.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize errorView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // make sure we're logged out
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
    [mnc logout];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRegistration:(id)sender
{
    
    // Create and configure a new instance of the TaloolCustomer entity.
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
    NSManagedObjectContext *context = mnc.managedObjectContext;
    ttCustomer *user = (ttCustomer *)[NSEntityDescription insertNewObjectForEntityForName:@"TaloolCustomer" inManagedObjectContext:context];
    [user setCreated:[NSDate date]];
    [user setFirstName:firstNameField.text];
    [user setLastName:lastNameField.text];
    [user setEmail:emailField.text];
    [user setPassword:passwordField.text];
    ttAddress *address = (ttAddress *)[NSEntityDescription insertNewObjectForEntityForName:@"TaloolAddress" inManagedObjectContext:context];
    [address setAddress1:addressField.text];
    [address setCity:cityField.text];
    [address setStateProvidenceCounty:stateField.text];
    [address setZip:zipField.text];
    [user setAddress:address];
    
    // Register the user.  Check the response and display errors as needed
    NSError *error = nil;
    CustomerController *cController = [[CustomerController alloc] init];
    if ([cController registerUser:user error:&error]) {
        NSError *cd_error = nil;
        if (![context save:&cd_error]) {
            [self showErrorMessage:cd_error.localizedDescription withTitle:@"oops!"];
        }
    } else {
        [self showErrorMessage:error.localizedDescription withTitle:@"yo!"];
    }
}

- (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title
{
	self.errorView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"try again" otherButtonTitles:nil];
	[self.errorView show];
}

@end
