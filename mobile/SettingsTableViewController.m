//
//  SetttingsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AppDelegate.h"
#import "CustomerHelper.h"
#import "FacebookSDK/FacebookSDK.h"
#import "WelcomeViewController.h"
#import "MyDealsViewController.h"
#import "TaloolMobileWebViewController.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "OperationQueueManager.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface SettingsTableViewController ()
@property (strong, nonatomic) UIView *accountHeader;
@property (strong, nonatomic) UIView *taloolHeader;
@end

@implementation SettingsTableViewController

@synthesize customer, accountHeader, taloolHeader;

static NSString *host = @"http://www.talool.com";

- (void)viewDidLoad
{
    [super viewDidLoad];
    customer = [CustomerHelper getLoggedInUser];
    nameLabel.text = [customer getFullName];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"version: %@, build: %@", version, build];
    
	self.navigationItem.title = @"Settings";
    
    [logoutButton useTaloolStyle];
    [logoutButton setBaseColor:[TaloolColor teal]];
    
    // create table headers
    accountHeader = [self createHeaderView:@"Account"];
    taloolHeader = [self createHeaderView:@"About Talool"];

}

- (UIView *) createHeaderView:(NSString *)title
{
    CGRect frame = self.view.bounds;
    CGRect headerFrame = CGRectMake(12.0,0.0,frame.size.width,60.0);
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:headerFrame];
    [headerTitle setTextColor:[TaloolColor gray_5]];
    headerTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:21.0];
    headerTitle.text = title;
    [headerTitle setBackgroundColor:[UIColor clearColor]];
    [header addSubview:headerTitle];
    
    return header;
}

- (void) viewWillAppear:(BOOL)animated
{
    
    if ([FBSession.activeSession isOpen] || [[CustomerHelper getLoggedInUser] isFacebookUser])
    {
        // hide the normal logout button and replace with a FB logout button
        [logoutButton setHidden:YES];
        [nameLabel setHidden:YES];
        FBLoginView *loginView = [[FBLoginView alloc] init];
        loginView.delegate = self;
        [loginView setTransform:CGAffineTransformMakeScale(.75, .75)];
        // Align the button in the center horizontally
        loginView.frame = CGRectOffset(loginView.frame,
                                       (logoutCell.viewForBaselineLayout.frame.size.width/2 - loginView.frame.size.width/2 - 20.0),
                                       -1);
        
        
        [logoutCell.viewForBaselineLayout addSubview:loginView];
        [loginView sizeToFit];
        
    }
    else
    {
        [logoutButton setHidden:NO];
        [nameLabel setHidden:NO];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"logout"])
    {
        WelcomeViewController *wvc = [segue destinationViewController];
        [wvc setHidesBottomBarWhenPushed:YES];
    }
    else if ([[segue identifier] isEqualToString:@"privacy"])
    {
        NSString *pUrl = [NSString stringWithFormat:@"%@/privacy",host];
        [[segue destinationViewController] setMobileWebUrl:pUrl];
        [[segue destinationViewController] setViewTitle:@"Privacy Policy"];
    }
    else if ([[segue identifier] isEqualToString:@"terms"])
    {
        NSString *tUrl = [NSString stringWithFormat:@"%@/termsofservice",host];
        [[segue destinationViewController] setMobileWebUrl:tUrl];
        [[segue destinationViewController] setViewTitle:@"Terms of Use"];
    }
    else if ([[segue identifier] isEqualToString:@"merchant"])
    {
        NSString *smUrl = [NSString stringWithFormat:@"%@/services/merchants",host];
        [[segue destinationViewController] setMobileWebUrl:smUrl];
        [[segue destinationViewController] setViewTitle:@"Merchant Services"];
    }
    else if ([[segue identifier] isEqualToString:@"publisher"])
    {
        NSString *spUrl = [NSString stringWithFormat:@"%@/services/publishers",host];
        [[segue destinationViewController] setMobileWebUrl:spUrl];
        [[segue destinationViewController] setViewTitle:@"Publisher Services"];
    }
    else if ([[segue identifier] isEqualToString:@"feedback"])
    {
        ttCustomer *user = [CustomerHelper getLoggedInUser];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *feedbackUrl = [NSString stringWithFormat:@"%@/feedback?fromEmail=%@&feedbackSrc=ios&version=%@&build=%@",host,user.email,version, build];
        NSLog(@"open url %@",feedbackUrl);
        [[segue destinationViewController] setMobileWebUrl:feedbackUrl];
        [[segue destinationViewController] setViewTitle:@"Feedback"];
    }
}

- (IBAction)logout:(id)sender
{
    // add a spinner
    [SVProgressHUD showWithStatus:@"Logging out" maskType:SVProgressHUDMaskTypeBlack];
    [[OperationQueueManager sharedInstance] startUserLogout:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    // the FB user has logged in
    
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
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
        [CustomerHelper showAlertMessage:alertMessage withTitle:alertTitle withCancel:@"OK" withSender:self];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"FACEBOOK"
                                                          action:@"LogoutButton"
                                                           label:error.domain
                                                           value:[NSNumber numberWithInteger:error.code]] build]];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    // the FB user has logged out
    // TODO, but this could also be a non-FB user...
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    
    if ([user isFacebookUser]) {
        [self logout:self];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return (section==0) ? accountHeader:taloolHeader;
}

#pragma mark -
#pragma mark - OperationQueueDelegate delegate

- (void) logoutComplete:(NSDictionary *)response
{
    // remove the spinner
    [SVProgressHUD dismiss];
    
    BOOL result = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (result)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:BRAINTREE_CLIENT_TOKEN_KEY];
        
        if ([FBSession.activeSession isOpen])
        {
            [FBSession.activeSession closeAndClearTokenInformation];
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate switchToLoginView];
    }
}

@end
