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
#import "WhiteLabelHelper.h"
#import "TaloolUIButton.h"
#import "FacebookHelper.h"
#import "TaloolColor.h"
#import "Talool-API/ttCustomer.h"
#import "MyDealsViewController.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "TextureHelper.h"
#import <OperationQueueManager.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface WelcomeViewController ()
- (IBAction)fbButtonClicked:(id)sender;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@property (strong, nonatomic) NSArray *fbPermissions;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *productName = [WhiteLabelHelper getProductName];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Welcome to %@", productName]];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];
    
    // check for a cached FB session
    _fbPermissions = @[@"public_profile", @"email", @"user_birthday", @"user_friends"];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Found a cached session");
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"APP"
                                                              action:@"FBSessionStateCreatedTokenLoaded"
                                                               label:@"auth_in_WelcomeViewController_viewDidLoad"
                                                               value:nil] build]];
        
        [SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeBlack];
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:_fbPermissions
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
    }
    
    [signinButton useTaloolStyle];
    [signinButton setBaseColor:[TaloolColor teal]];
    [signinButton setTitle:[NSString stringWithFormat:@"Log in with %@", productName] forState:UIControlStateNormal];
    
    [facebookButton useTaloolStyle];
    [facebookButton setBaseColor:[UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1.0]];
    [facebookButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    
    [regButton setTitleColor:[TaloolColor dark_teal] forState:UIControlStateNormal];

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
    
    if ([CustomerHelper getLoggedInUser]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidUnload {
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
        if (_failedUser)
        {
            [[segue destinationViewController] setFailedUser:_failedUser];
            _failedUser = nil;
        }
    }
    else if ([[segue identifier] isEqualToString:@"welcome_to_mydeals"])
    {
        [self.navigationController setNavigationBarHidden:YES];
        TaloolTabBarController *controller = [segue destinationViewController];
        [controller resetViews];
    }
}


#pragma mark -
#pragma mark - Facebook methods

- (IBAction)fbButtonClicked:(id)sender
{
    [SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeBlack];
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self userLoggedInWithFacebook];
    }
    else
    {
        FBSessionStateHandler completionHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
            [self sessionStateChanged:session state:status error:error];
        };
        
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            // we have a cached token, so open the session
            [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                                      completionHandler:completionHandler];
        } else {
            [self clearAllUserInfo];
            // create a new facebook session
            FBSession *fbSession = [[FBSession alloc] initWithPermissions:@[@"email", @"user_location"]];
            [FBSession setActiveSession:fbSession];
            [fbSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                      completionHandler:completionHandler];
        }
    }
}

- (void) clearAllUserInfo
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
        NSLog(@"%@", error);
    }];
    [FBSession setActiveSession:nil];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        [self userLoggedInWithFacebook];
    }
    else if (error)
    {
        [self handleFacebookError:error];
    }
}

- (void)userLoggedInWithFacebook
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
     {
         if (!error)
         {
             [[OperationQueueManager sharedInstance] authFacebookUser:user delegate:self];
         }
         else
         {
             [self handleFacebookError:error];
         }
     }];
}

- (void)handleFacebookError:(NSError *)error
{
    // remove the spinner
    [SVProgressHUD dismiss];
    
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser)
    {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    }
    else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession)
    {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    }
    else if (error.fberrorCategory == FBErrorCategoryUserCancelled)
    {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    }
    else
    {
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
    
    if (alertMessage)
    {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"FACEBOOK"
                                                              action:@"LoginButton"
                                                               label:error.domain
                                                               value:[NSNumber numberWithInteger:error.code]] build]];
        
        [CustomerHelper showAlertMessage:alertMessage withTitle:alertTitle withCancel:@"OK" withSender:self];
    }
}


#pragma mark -
#pragma mark - OperationQueueDelegate delegate

- (void)userAuthComplete:(NSDictionary *)response
{
    // remove the spinner
    [SVProgressHUD dismiss];
    
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    
    if (success && customer)
    {
        [FacebookHelper trackNumberOfFriends];
        
        [[OperationQueueManager sharedInstance] handleForegroundState];
        
        [self performSegueWithIdentifier:@"welcome_to_mydeals" sender:self];
        
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        if (error)
        {
            // Fail if don't get what we need from Facebook.  Sending the user to the
            // normal registration form could cause it's own problems right now
            // For example, we don't want them to create a different password.
            // A missing birthday won't cause a problem b/c that field is optional.
            
            // Reg failed so log out of Facebook
            [[FBSession activeSession] closeAndClearTokenInformation];
            
            // show error message (CustomerHelper.loginFacebookUser doesn't handle this)
            [CustomerHelper showAlertMessage:error.localizedDescription
                                   withTitle:@"Authentication Failed"
                                  withCancel:@"Try again"
                                  withSender:nil];

        }
        else
        {
            // logout of facebook
            [[FBSession activeSession] closeAndClearTokenInformation];
            
            NSLog(@"FAIL: No user stored after authentication");
            
            // show error message (CustomerHelper.loginFacebookUser doesn't handle this)
            [CustomerHelper showAlertMessage:@"We were unable to store your credentials."
                                   withTitle:@"Authentication Failed"
                                  withCancel:@"Try again"
                                  withSender:nil];
        }
    }
    
}


@end
