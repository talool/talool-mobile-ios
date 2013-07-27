//
//  SetttingsTableViewController.m
//  Talool
//
//  Created by Douglas McCuen on 3/28/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "CustomerHelper.h"
#import "AppDelegate.h"
#import "FacebookSDK/FacebookSDK.h"
#import "WelcomeViewController.h"
#import "MyDealsViewController.h"
#import "TaloolMobileWebViewController.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "talool-api-ios/GAI.h"

@interface SettingsTableViewController ()
@property (strong, nonatomic) UIView *accountHeader;
@property (strong, nonatomic) UIView *taloolHeader;
@end

@implementation SettingsTableViewController

@synthesize customer, spinner, accountHeader, taloolHeader;


- (void)viewDidLoad
{
    [super viewDidLoad];
    customer = [CustomerHelper getLoggedInUser];
    nameLabel.text = [customer getFullName];
	self.navigationItem.title = @"Settings";
    
    [logoutButton useTaloolStyle];
    [logoutButton setBaseColor:[TaloolColor teal]];
    
    // create table headers
    accountHeader = [self createHeaderView:@"Account"];
    taloolHeader = [self createHeaderView:@"About Talool"];
    
    spinner.hidesWhenStopped=YES;
    
    UIImageView *texture = [[UIImageView alloc] initWithFrame:self.view.bounds];
    texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:self.view.bounds.size];
    [texture setAlpha:0.15];
    [self.tableView setBackgroundView:texture];
}

- (UIView *) createHeaderView:(NSString *)title
{
    CGRect frame = self.view.bounds;
    CGRect headerFrame = CGRectMake(12.0,0.0,frame.size.width,60.0);
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:headerFrame];
    [headerTitle setTextColor:[UIColor whiteColor]];
    headerTitle.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:21.0];
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
                                       2);
        
        
        [logoutCell.viewForBaselineLayout addSubview:loginView];
        [loginView sizeToFit];
        
    }
    else
    {
        [logoutButton setHidden:NO];
        [nameLabel setHidden:NO];
    }
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
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
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/privacy"];
        [[segue destinationViewController] setViewTitle:@"Privacy Policy"];
    }
    else if ([[segue identifier] isEqualToString:@"terms"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/terms"];
        [[segue destinationViewController] setViewTitle:@"Terms of Service"];
    }
    else if ([[segue identifier] isEqualToString:@"merchant"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/services/merchants"];
        [[segue destinationViewController] setViewTitle:@"Merchant Services"];
    }
    else if ([[segue identifier] isEqualToString:@"publisher"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/services/publishers"];
        [[segue destinationViewController] setViewTitle:@"Publisher Services"];
    }
    else if ([[segue identifier] isEqualToString:@"feedback"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/feedback"];
        [[segue destinationViewController] setViewTitle:@"Feedback"];
    }
    else if ([[segue identifier] isEqualToString:@"partnership"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/payback/partnership"];
        [[segue destinationViewController] setViewTitle:@"Feedback"];
    }
    else if ([[segue identifier] isEqualToString:@"boulder"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://dev-www.talool.com/payback/boulder"];
        [[segue destinationViewController] setViewTitle:@"Boulder"];
    }
    else if ([[segue identifier] isEqualToString:@"vancouver"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://dev-www.talool.com/payback/vancouver"];
        [[segue destinationViewController] setViewTitle:@"Vancouver"];
    }
    else if ([[segue identifier] isEqualToString:@"faq"])
    {
        [[segue destinationViewController] setMobileWebUrl:@"http://www.talool.com/faq"];
        [[segue destinationViewController] setViewTitle:@"FAQ"];
    }
}

- (IBAction)logout:(id)sender
{
    // add a spinner
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    [self logoutUser];
     
     // remove the spinner
     [spinner stopAnimating];
    
    [self performSegueWithIdentifier:@"logout" sender:self];

}

// Called from other controllers as needed
- (void)logoutUser
{
    // CHECK FOR A FACEBOOK SESSION
    if ([FBSession.activeSession isOpen]) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ttCustomer logoutUser:appDelegate.managedObjectContext];
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
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"FACEBOOK"
                        withAction:@"LogoutButton"
                         withLabel:error.domain
                         withValue:[NSNumber numberWithInteger:error.code]];
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

@end
