//
//  SplashViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SplashViewController.h"
#import "UIImage+H568.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <WhiteLabelHelper.h>
#import <AppDelegate.h>
#import "TestFlight.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "TaloolAppCall.h"
#import "CustomerHelper.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize defaultImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaultImage.image = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"Default.png"]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    
    // do this async, so the spinner shows up
    dispatch_async(dispatch_get_main_queue(),^{
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setupApp) userInfo:nil repeats:NO];
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupApp
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate setUserAgent];
    
    // Get the Device Token
    // For now, register for all types of notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        UIUserNotificationSettings* notificationSettings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
           (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    // Request background refresh interval
    appDelegate.minUpdateInterval = UIApplicationBackgroundFetchIntervalMinimum;
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:appDelegate.minUpdateInterval];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // Set up root view controller options
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    appDelegate.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    appDelegate.loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavController"];
    
    // Google Analytics
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithName:@"Talool" trackingId:GA_TRACKING_ID];
    
    // Test Flight
    [TestFlight setOptions:@{ TFOptionSessionKeepAliveTimeout : @60 }];
    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
    
    // Delayed Finalization
    if ([WhiteLabelHelper getTaloolDictionary])
    {
        // it's a white label, so delay to show the "powered by talool"
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(finalizeSetup) userInfo:nil repeats:NO];
    }
    else
    {
        [self finalizeSetup];
    }
}

- (void) finalizeSetup
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([CustomerHelper getLoggedInUser])
    {
        // show the main view
        [appDelegate switchToMainView];
    }
    else
    {
        // show the login view
        [appDelegate switchToLoginView];
    }
    
    [[TaloolAppCall sharedInstance] handleDidBecomeActive];
}

@end
