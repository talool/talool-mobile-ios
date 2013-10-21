//
//  EmailViewController.h
//  Talool
//
//  Created by Douglas McCuen on 10/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, TaloolTextField, ttCustomer;

@interface EmailViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate>
{
    IBOutlet TaloolTextField *emailField;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet TaloolUIButton *saveButton;
    IBOutlet UIButton *cancelButton;
}

- (IBAction)saveAction:(id) sender;
- (IBAction)cancelAction:(id) sender;

@property (retain, nonatomic) ttCustomer *customer;

@end
