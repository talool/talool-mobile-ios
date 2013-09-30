//
//  LoginViewController.h
//  Talool
//
//  Created by Douglas McCuen on 9/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface LoginViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet TaloolUIButton *signinButton;
}

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
