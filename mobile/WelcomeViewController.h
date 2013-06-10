//
//  WelcomeViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TaloolProtocols.h"

@class TaloolIconButton, TaloolUIButton;

@interface WelcomeViewController : UIViewController<FBLoginViewDelegate>
{
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *passwordField;
    IBOutlet TaloolUIButton *loginButton;
    IBOutlet TaloolIconButton *regButton;
    IBOutlet UIActivityIndicatorView *spinner;
    id <TaloolLogoutDelegate> logoutDelegate;
}

- (IBAction)logoutAction:(UIStoryboardSegue *)segue;
- (IBAction)loginAction:(id) sender;
- (void) registerLogoutDelegate:(id <TaloolLogoutDelegate>)delegate;

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;
@property (retain, nonatomic) UIActivityIndicatorView *spinner;

@end
