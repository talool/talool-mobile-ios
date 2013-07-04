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
    IBOutlet UIImageView *texture;
    IBOutlet UIScrollView *scroller;
    UIAlertView *errorView;
    
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) UIAlertView *errorView;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
