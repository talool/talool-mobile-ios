//
//  SendPasswordResetViewController.h
//  Talool
//
//  Created by Douglas McCuen on 9/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface SendPasswordResetViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *emailField;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet TaloolUIButton *sendEmailButton;
}

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
