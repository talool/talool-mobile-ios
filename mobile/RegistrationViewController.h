//
//  RegistrationViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, TaloolTextField;

@interface RegistrationViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate> {
    IBOutlet TaloolTextField *emailField;
    IBOutlet TaloolTextField *passwordField;
    IBOutlet TaloolTextField *firstNameField;
    IBOutlet TaloolTextField *lastNameField;
    UIAlertView *errorView;
    
    IBOutlet TaloolUIButton *regButton;
    IBOutlet UIActivityIndicatorView *spinner;
}

- (IBAction)regAction:(id)sender;

@property (nonatomic, retain) UIAlertView *errorView;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
