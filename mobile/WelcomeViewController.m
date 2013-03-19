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
#import "FacebookHelper.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.FBLoginView.readPermissions = @[@"user_location", @"email"];
    self.FBLoginView.publishPermissions = @[@"publish_actions"];
    self.FBLoginView.defaultAudience = FBSessionDefaultAudienceFriends;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
                 
                 // If there is not saved user (in core data), but there is an active FB session
                 // Then we should create the user (if needed) and save the user (to core data)
                 if ([CustomerHelper getLoggedInUser] == nil) {
                     ttCustomer *customer = [CustomerHelper createCustomerFromFacebookUser:user];
                     // check if this user is already registered
                     if ([CustomerHelper doesCustomerExist:customer.email]) {
                         // TODO auth the user... could be hard with random password
                         [CustomerHelper loginUser:customer.email password:customer.password];
                     } else {
                         [CustomerHelper registerCustomer:customer];
                     }
                     
                     //[FacebookHelper getFriends];
                 }
                 
                 // If we have a logged in user (possibly as a result of the FB reg above)
                 // Then we should check if any FB data has changed and navigate to the main view
                 if ([CustomerHelper isUserLoggedIn]) {
                     // TODO consider updating the user if needed
                     AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
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
    [CustomerHelper logoutUser];
    if ([CustomerHelper isUserLoggedIn]) {
        NSLog(@"OH SHIT!!!! The user isn't completely logged out");
    }
}


- (IBAction)logoutAction:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"logoutUser"]) {
        [self logOut];
    }
}

- (IBAction)loginAction:(id) sender
{
    // make sure we're logged out
    [CustomerHelper logoutUser];
    
    [CustomerHelper loginUser:emailField.text password:passwordField.text];
    
    // don't leave the page if reg failed
    if ([CustomerHelper isUserLoggedIn]) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
    }
}

@end
