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

@interface RegistrationViewController : UIViewController<TaloolKeyboardAccessoryDelegate> {
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *firstNameField;
    IBOutlet UITextField *lastNameField;
    IBOutlet TaloolUIButton *regButton;
    IBOutlet UIImageView *texture;
    IBOutlet UIScrollView *scroller;
    UIAlertView *errorView;
    
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) UIAlertView *errorView;

- (IBAction) onRegistration:(id) sender;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
