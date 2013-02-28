//
//  RegistrationViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MasterNavigationController.h"
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
    // if we have a user, we can skip Registration.
    MasterNavigationController *mnc = (MasterNavigationController *)(self.navigationController);
    if (mnc.user != nil) {
        [self performSegueWithIdentifier:@"userRegistered" sender:self.navigationController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRegistration:(id)sender
{
    
    // Create and configure a new instance of the TaloolUser entity.
    NSManagedObjectContext *context = ((MasterNavigationController *)(self.navigationController)).managedObjectContext;
    TaloolUser *user = (TaloolUser *)[NSEntityDescription insertNewObjectForEntityForName:@"TaloolUser" inManagedObjectContext:context];
    [user setCreationDate:[NSDate date]];
    [user setFirstName:emailField.text];
    [user setLastName:passwordField.text];
    [user setEmail:emailField.text];
    
    // Register the user.  Check the response and display errors as needed
    NSError *error = nil;
    CustomerController *cController = [[CustomerController alloc] init];
    if ([cController registerUser:user error:&error]) {
        // persist the user in the context
        NSError *cd_error = nil;
        if ([context save:&cd_error]) {
            [self performSegueWithIdentifier:@"userRegistered" sender:sender];
        } else {
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
