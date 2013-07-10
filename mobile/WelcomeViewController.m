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
#import "SettingsTableViewController.h"
#import "MyDealsViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[TaloolColor gray_2]];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        // Push forward if we already have a user
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //[self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
        [appDelegate.settingsViewController logoutUser];
    }
    
    // TODO: set up FB permissions
    /* there are a ton of permissions to consider
     https://developers.facebook.com/docs/reference/login/extended-permissions/
     
     user_birthday (friends_birthday)
     user_likes
     publish_actions, publish_checkins
     
     */
    self.FBLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"email",@"user_birthday"]];
    
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
    
    spinner.hidesWhenStopped=YES;
    self.navigationItem.hidesBackButton = YES;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showReg"])
    {
        [[segue destinationViewController] registerAuthDelegate:authDelegate];
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    }
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if (FBSession.activeSession.isOpen && [CustomerHelper getLoggedInUser] == nil) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                 // If there is not saved user (in core data), but there is an active FB session
                 // Then we should create the user (if needed) and save the user (to core data)
                 if ([CustomerHelper getLoggedInUser] == nil) {
                     
                     // add a spinner
                     [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
                     
                     ttCustomer *customer = [FacebookHelper createCustomerFromFacebookUser:user];
                     
                     // TODO: see if we have come up with a better method to generate a password for FB users
                     NSString *passwordHack = [ttCustomer nonrandomPassword:[user objectForKey:@"email"]];
                     
                     if ([ttCustomer doesCustomerExist:customer.email]) {
                         // auth the user
                         [CustomerHelper loginUser:customer.email password:passwordHack];
                     } else {
                         [CustomerHelper registerCustomer:customer password:passwordHack];
                     }
                     
                     // remove the spinner
                     [spinner stopAnimating];
                     
                 }
                 
                 // If we have a logged in user (possibly as a result of the FB reg above)
                 // Then we should check if any FB data has changed and navigate to the main view
                 if ([CustomerHelper getLoggedInUser] != nil) {
                     [authDelegate customerLoggedIn:self];
                     // TODO consider updating the user if needed
                     if (self.navigationController.visibleViewController != appDelegate.firstViewController) {
                         [self.navigationController popToRootViewControllerAnimated:YES];
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
    // NOTE: We don't want to log the user out here.  If they were never connected with FB,
    //      this would invalidate their token everything they quit the app and reopen it.
    //      Consider checking if the user has a FB account before logging them out...
    //      But this could still cause problems.0
    //
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    if ([customer isFacebookUser])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.isNavigating) {
            // The delay is for the edge case where a session is immediately closed after
            // logging in and our navigation controller is still animating a push.
            [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
        } else {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.settingsViewController logoutUser];
        }
    }
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

- (IBAction)loginAction:(id) sender
{
    // add a spinner
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    // don't leave the page if login failed
    if ([CustomerHelper loginUser:emailField.text password:passwordField.text]) {
        [authDelegate customerLoggedIn:self];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    // remove the spinner
    [spinner stopAnimating];
}

- (void) registerAuthDelegate:(id <TaloolAuthenticationDelegate>)delegate
{
    authDelegate = delegate;
}


@end
