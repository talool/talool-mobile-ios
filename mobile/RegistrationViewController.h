//
//  RegistrationViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolUser.h"


@interface RegistrationViewController : UIViewController {
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    UIAlertView *errorView;
}

@property (nonatomic, retain) UIAlertView *errorView;

- (IBAction) onRegistration:(id) sender;

@end
