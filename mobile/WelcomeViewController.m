//
//  WelcomeViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "TaloolTabBarController.h"
#import "CustomerHelper.h"
#import "TaloolIconButton.h"
#import "TaloolUIButton.h"
#import "FacebookHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"
#import "talool-api-ios/ttCustomer.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[TaloolColor gray_2]];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        // Push forward if we already have a user
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
    }
    
    // TODO: set up FB permissions
    /* there are a ton of permissions to consider
     https://developers.facebook.com/docs/reference/login/extended-permissions/
     
     user_birthday (friends_birthday)
     user_likes
     publish_actions, publish_checkins
     
     */
    self.FBLoginView = [[FBLoginView alloc] init];
    self.FBLoginView.readPermissions = @[@"email",@"user_birthday"];
    
    [loginButton useTaloolStyle];
    [loginButton setBaseColor:[TaloolColor teal]];
    
    NSDictionary *attr = @{ FAKImageAttributeForegroundColor:[UIColor whiteColor] };
    UIImage *userIcon = [FontAwesomeKit imageForIcon:FAKIconUser
                                           imageSize:CGSizeMake(44, 44)
                                            fontSize:36
                                          attributes:attr];
    [regButton useTaloolStyle];
    [regButton setBaseColor:[TaloolColor teal]];
    [regButton setTitle:@"Register" forState:UIControlStateNormal];
    [regButton setImage:userIcon forState:UIControlStateNormal];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [self setFBLoginView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                 // If there is not saved user (in core data), but there is an active FB session
                 // Then we should create the user (if needed) and save the user (to core data)
                 if ([CustomerHelper getLoggedInUser] == nil) {
                     ttCustomer *customer = [FacebookHelper createCustomerFromFacebookUser:user];
                     
                     // TODO: see if we have come up with a better method to generate a password for FB users
                     NSString *passwordHack = [ttCustomer nonrandomPassword:[user objectForKey:@"email"]];
                     
                     if ([ttCustomer doesCustomerExist:customer.email]) {
                         // auth the user
                         [CustomerHelper loginUser:customer.email password:passwordHack];
                         ttCustomer *customer = [CustomerHelper getLoggedInUser];
                         // TODO check for the FB account specifically
                         if ([customer.socialAccounts count] == 0) {
                             // add the social account
                             ttSocialAccount *sa = [FacebookHelper createSocialAccount:user];
                             // check for the presence of the social account
                             [customer addSocialAccountsObject:sa];
                             // save the user so the social account is stored
                             [ttCustomer saveCustomer:customer context:appDelegate.managedObjectContext error:nil];
                         }
                         
                         
                     } else {
                         [CustomerHelper registerCustomer:customer password:passwordHack];
                     }
                     
                 }
                 
                 // If we have a logged in user (possibly as a result of the FB reg above)
                 // Then we should check if any FB data has changed and navigate to the main view
                 if ([CustomerHelper getLoggedInUser] != nil) {
                     // TODO consider updating the user if needed
                     if (self.navigationController.visibleViewController != appDelegate.mainViewController) {
                         [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
                     }
                 }
                 
             }
         }];

    }
    
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isNavigating) {
        // The delay is for the edge case where a session is immediately closed after
        // logging in and our navigation controller is still animating a push.
        [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
    } else {
        [self logOut];
    }
}

- (void)logOut
{
    // CHECK FOR A FACEBOOK SESSION
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ttCustomer logoutUser:appDelegate.managedObjectContext];
}


- (IBAction)logoutAction:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"logoutUser"]) {
        [self logOut];
    }
}

- (IBAction)loginAction:(id) sender
{
    // don't leave the page if login failed
    if ([CustomerHelper loginUser:emailField.text password:passwordField.text]) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
    }
}


@end
