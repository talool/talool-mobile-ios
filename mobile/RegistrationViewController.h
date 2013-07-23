//
//  RegistrationViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface RegistrationViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate> {
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *firstNameField;
    IBOutlet UITextField *lastNameField;
    UIAlertView *errorView;
    
    IBOutlet UIActivityIndicatorView *spinner;
    
    id <TaloolAuthenticationDelegate> authDelegate;
}

@property (nonatomic, retain) UIAlertView *errorView;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

- (void) registerAuthDelegate:(id <TaloolAuthenticationDelegate>)delegate;

@end
