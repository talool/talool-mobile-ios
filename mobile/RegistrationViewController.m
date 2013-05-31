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
#import "TaloolColor.h"
#import "TaloolUIButton.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize errorView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [regButton useTaloolStyle];
    [regButton setBaseColor:[TaloolColor teal]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRegistration:(id)sender
{
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
        [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
    }
    
}

@end
