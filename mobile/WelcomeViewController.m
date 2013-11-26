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
#import "TaloolUIButton.h"
#import "FacebookHelper.h"
#import "TaloolColor.h"
#import "Talool-API/ttCustomer.h"
#import "EmailViewController.h"
#import "MyDealsViewController.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "TextureHelper.h"
#import <OperationQueueManager.h>

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

@synthesize spinner, FBLoginView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Welcome to Talool"];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        [CustomerHelper logoutUser];
    }
    
    // TODO: set up FB permissions
    /* there are a ton of permissions to consider
     https://developers.facebook.com/docs/reference/login/extended-permissions/
     
     user_birthday (friends_birthday)
     user_likes
     publish_actions, publish_checkins
     
     */
    self.FBLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"email",@"user_birthday"]];
    
    [signinButton useTaloolStyle];
    [signinButton setBaseColor:[TaloolColor teal]];
    [signinButton setTitle:@"Log in with Talool" forState:UIControlStateNormal];
    
    spinner.hidesWhenStopped=YES;
    self.navigationItem.hidesBackButton = YES;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Welcome Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    }
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if (FBSession.activeSession.isOpen && [CustomerHelper getLoggedInUser] == nil) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {

                 if ([CustomerHelper getLoggedInUser])
                 {
                     [FacebookHelper trackNumberOfFriends];
                     [self.navigationController popToRootViewControllerAnimated:YES];
                 }
                 else
                 {
                     [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
                     [[OperationQueueManager sharedInstance] authFacebookUser:user delegate:self];
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
        NSError *innerError = [error.userInfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"];
        if (innerError.code == -1009)
        {
            alertTitle  = @"No Internet Connection";
            alertMessage = @"You appear to be offline.  Please try again later.";
        }
        else
        {
            // For simplicity, this sample treats other errors blindly, but you should
            // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
            alertTitle  = @"Unknown Error";
            alertMessage = @"Error. Please try again later.";
            NSLog(@"Unexpected error:%@", error);
        }
        
    }
    
    if ([FBSession activeSession].isOpen)
    {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    
    if (alertMessage) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"FACEBOOK"
                                                              action:@"LoginButton"
                                                               label:error.domain
                                                               value:[NSNumber numberWithInteger:error.code]] build]];
        
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
        [CustomerHelper logoutUser];
    }
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}


#pragma mark -
#pragma mark - OperationQueueDelegate delegate

- (void)userAuthComplete:(NSError *)error
{
    // remove the spinner
    [spinner stopAnimating];
    
    if (error)
    {

#warning "TODO handle the user is incomplete and open the reg form with the FB user obj seeding the form"
        
        // show error message (CustomerHelper.loginFacebookUser doesn't handle this)
        [CustomerHelper showErrorMessage:error.localizedDescription
                               withTitle:@"Authentication Failed"
                              withCancel:@"Try again"
                              withSender:nil];
        // logout of facebook
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    else
    {
        [FacebookHelper trackNumberOfFriends];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
