//
//  RegistrationViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttAddress.h"


@interface RegistrationViewController : UIViewController {
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *firstNameField;
    IBOutlet UITextField *lastNameField;
    IBOutlet UITextField *addressField;
    IBOutlet UITextField *cityField;
    IBOutlet UITextField *stateField;
    IBOutlet UITextField *zipField;
    UIAlertView *errorView;
}

@property (nonatomic, retain) UIAlertView *errorView;

- (IBAction) onRegistration:(id) sender;

@end
