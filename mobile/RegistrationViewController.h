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

@interface RegistrationViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate, OperationQueueDelegate> {
    IBOutlet TaloolTextField *emailField;
    IBOutlet TaloolTextField *passwordField;
    IBOutlet TaloolTextField *firstNameField;
    IBOutlet TaloolTextField *lastNameField;
    IBOutlet TaloolTextField *birthDateField;
    IBOutlet UISegmentedControl *sexPicker;
    IBOutlet UITableViewCell *datePickerCell;
    IBOutlet UIDatePicker *datePicker;
    
    UIAlertView *errorView;
    
    IBOutlet TaloolUIButton *regButton;
    IBOutlet UIActivityIndicatorView *spinner;
}

- (IBAction)dateChanged:(id)sender;

- (IBAction)regAction:(id)sender;
- (IBAction)dateAction:(id)sender;

@property (nonatomic, retain) UIAlertView *errorView;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
