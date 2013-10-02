//
//  ResetPasswordViewController.h
//  Talool
//
//  Created by Douglas McCuen on 9/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, TaloolTextField;

@interface ResetPasswordViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate>
{
    IBOutlet TaloolTextField *passwordField;
    IBOutlet TaloolTextField *confirmPasswordField;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet TaloolUIButton *changePasswordButton;
}

@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (retain, nonatomic) NSString *customerId;
@property (retain, nonatomic) NSString *resetCode;

@end