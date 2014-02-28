//
//  LoginViewController.h
//  Talool
//
//  Created by Douglas McCuen on 9/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, TaloolTextField;

@interface LoginViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate, OperationQueueDelegate>
{
    IBOutlet TaloolTextField *emailField;
    IBOutlet TaloolTextField *passwordField;
    IBOutlet TaloolUIButton *signinButton;
    IBOutlet UIButton *forgotButton;
}

@end
