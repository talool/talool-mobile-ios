//
//  AppDelegate.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AppDelegate.h"
#import "FacebookSDK/FacebookSDK.h"
#import "FacebookSDK/FBSessionTokenCachingStrategy.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/ttActivity.h"
#import "TaloolColor.h"
#import "TaloolTabBarController.h"
#import "WelcomeViewController.h"
#import "SettingsTableViewController.h"
#import "MyDealsViewController.h"
#import "ActivityViewController.h"
#import "SplashViewController.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "TaloolAppCall.h"
#import "TestFlight.h"
#import "BraintreeHelper.h"
#import <OperationQueueManager.h>
#import "LocationHelper.h"
#import "CustomerHelper.h"
#import "WhiteLabelHelper.h"
#import "ActivityOperation.h"
#import "TutorialViewController.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize window = _window,
            navigationController = _navigationController,
            mainViewController = _mainViewController,
            loginViewController = _loginViewController,
            isNavigating = _isNavigating,
            isSplashing = _isSplashing;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize splashView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //#warning @"Environment set to dev"
    //[[TaloolFrameworkHelper sharedInstance] setEnvironment:EnvironmentTypeDevelopment];
    
    //For now, register for all types of notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        UIUserNotificationSettings* notificationSettings =
            [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
            (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    //Request background refresh interval
    self.minUpdateInterval = UIApplicationBackgroundFetchIntervalMinimum;
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:self.minUpdateInterval];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    self.splashView = [storyboard instantiateViewControllerWithIdentifier:@"SplashView"];
    [self.window addSubview:self.splashView.view];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = self.splashView;

    // Dispatch a new thread so we'll see the Splash View and the user will get the progress spinner
    [NSThread detachNewThreadSelector:@selector(setupApp) toTarget:self withObject:nil];
    
    self.isSplashing = YES;
    
    return YES;
}

- (void) setupApp
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    self.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"]; // Handy reference to the tab controller
    self.loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"]; // Used for FB errors
    
    // Back to the main thread for the work that needs to happen there
    if ([WhiteLabelHelper getTaloolDictionary])
    {
        // it's a white label, so delay to show the "powered by talool"
        dispatch_async(dispatch_get_main_queue(),^{
            [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(finalizeSetup) userInfo:nil repeats:NO];
        });
    }
    else
    {
        [self performSelectorOnMainThread:@selector(finalizeSetup) withObject:nil waitUntilDone:NO];
    }
    
}

- (void) finalizeSetup
{
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithName:@"Talool" trackingId:GA_TRACKING_ID];
    
    
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    // create the signal action structure
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &SignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    // Call takeOff after install your own unhandled exception and signal handlers
    [TestFlight setOptions:@{ TFOptionSessionKeepAliveTimeout : @60 }];
    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
    
    [Crashlytics startWithAPIKey:@"621dd92cb7c068e9486411b53478071c2c3f5357"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogin:)
                                                 name:LOGIN_NOTIFICATION
                                               object:nil];
    
    [self.splashView.view removeFromSuperview];
    self.isSplashing = NO;
    
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    [[TaloolAppCall sharedInstance] handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if (!url || ![url absoluteString]) {
        return NO;
    }
    
    if ([[url scheme] isEqualToString:@"talool"]) {
        [[TaloolAppCall sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
        return YES;
    }
    
    if ([[url scheme] isEqualToString:@"taloolmydeals"]) {
        // TODO: add logic to parse the url/query/fragments to set app properties.
        // the next stop in the lifecycle is applicationDidBecomeActive:
        return YES;
    }
    
    // Facebook SDK * login flow *
    // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
    //if ([[FBSession activeSession] handleOpenURL:url]) {
    if ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication])
    {
        NSString *query = [url fragment];
        if (!query) {
            query = [url query];
        }
        NSDictionary *params = [self parseURLParams:query];
        // Check if target URL exists
        NSString *targetURLString = [params valueForKey:@"target_url"];
        if (targetURLString) {
            NSURL *targetURL = [NSURL URLWithString:targetURLString];
            NSString *taloolUrlString = [NSString stringWithFormat:@"talool:/%@", [targetURL path]];
            NSURL *taloolUrl = [NSURL URLWithString:taloolUrlString];
            [[TaloolAppCall sharedInstance] handleOpenURL:taloolUrl sourceApplication:sourceApplication];
        }
        return YES;
    } else {
        // Facebook SDK * App Linking *
        // For simplicity, this sample will ignore the link if the session is already
        // open but a more advanced app could support features like user switching.
        // Otherwise extract the app link data from the url and open a new active session from it.
        NSString *appID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
        FBAccessTokenData *appLinkToken = [FBAccessTokenData createTokenFromFacebookURL:url
                                                                                  appID:appID
                                                                        urlSchemeSuffix:nil];
        if (appLinkToken) {
            if (![FBSession activeSession].isOpen) {
                [self handleAppLink:appLinkToken];
                return YES;
            }
        }
    }
    return NO;
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{

    // You should be extremely careful when handling URL requests.
    // You must take steps to validate the URL before handling it.
    
    if (!url) {
        // The URL is nil. There's nothing more to do.
        return NO;
    }
    
    NSString *URLString = [url absoluteString];
    
    if (!URLString) {
        // The URL's absoluteString is nil. There's nothing more to do.
        return NO;
    }
    
    // Your application is defining the new URL type, so you should know the maximum character
    // count of the URL. Anything longer than what you expect is likely to be dangerous.
    NSInteger maximumExpectedLength = 50;
    
    if ([URLString length] > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
        return NO;
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[OperationQueueManager sharedInstance] handleBackgroundState];
    [[LocationHelper sharedInstance] handleBackgroundState];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    //[[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[TaloolAppCall sharedInstance] handleDidBecomeActive];
    [FBAppCall handleDidBecomeActive];
    [[OperationQueueManager sharedInstance] handleForegroundState];
    
    [[LocationHelper sharedInstance] handleForegroundState];

    [self setUserAgent];
    [[TaloolFrameworkHelper sharedInstance] setWhiteLabelId:[WhiteLabelHelper getWhiteLabelId]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return NO;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return NO;
}

// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              if (error) {
                                  NSLog(@"FB login error %@",error);
#warning "TODO handle errors"
                              }
                          }];
}

-(void) presentNewDeals
{
    
    if (self.mainViewController.selectedIndex > 0)
    {

        // the user is on FindDeals or Activity, so we should ask if they want to be redirected
        UIAlertView *showMe = [[UIAlertView alloc] initWithTitle:@"You've Got New Deals!"
                                                            message:@"We've updated your account with new deals.  Would you like to see them now?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes",nil];
        [showMe show];

    }

}

-(void) setUserAgent
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // You can get a real useragent by plucking it from a webview, but that is overkill
    //
    // UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    // NSString *secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    //
    // That will return something like:
    // Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/11B554a
    
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    iosVersion = [iosVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    iosVersion = [NSString stringWithFormat:@"iPhone; CPU iPhone OS %@ like Mac OS X",iosVersion];
    
    [[TaloolFrameworkHelper sharedInstance] setUserAgent:appVersion iosVersion:iosVersion];
}

#pragma mark - UIAlertViewDelegate 

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
    {
        // take the user to the "my deals" tab
        [self.mainViewController setSelectedIndex:0];
        [self.mainViewController.selectedViewController.navigationController popToRootViewControllerAnimated:NO];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    NSThread *thisThread = [NSThread currentThread];
    if (thisThread == [NSThread mainThread])
    {
        if (_managedObjectContext != nil) {
            return _managedObjectContext;
        }
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_managedObjectContext setStalenessInterval:0];
        }
        return _managedObjectContext;
    }
    else
    {
        //Return separate MOC for each new thread
        NSManagedObjectContext *threadManagedObjectContext = [[thisThread threadDictionary] objectForKey:@"MOC_KEY"];
        if (threadManagedObjectContext == nil)
        {
            threadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [threadManagedObjectContext setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
            [threadManagedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
            [[thisThread threadDictionary] setObject:threadManagedObjectContext forKey:@"MOC_KEY"];
                                          
        }
        return threadManagedObjectContext;
    }
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // if there is a white label id, use it as a prefix to our standard storePath "mobile.sqlite".
    // NOTE: don't change the store path for Talool from "mobile.sqlite"
    NSString *whiteLabelId = [WhiteLabelHelper getWhiteLabelId];
    NSString *storePath = [NSString stringWithFormat:@"%@%@",whiteLabelId,@"mobile.sqlite"];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storePath];
    _persistentStoreCoordinator = [TaloolPersistentStoreCoordinator initWithStoreUrl:storeURL];
        
    return _persistentStoreCoordinator;
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    [[OperationQueueManager sharedInstance] startActivityOperation:nil completionHander:^(NSDictionary *response, NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
        }else{
            NSNumber *num = [response valueForKey:@"openCount"];
            if (!num) num=0;
            if(num > 0)
            {
                [UIApplication sharedApplication].applicationIconBadgeNumber = [num integerValue];
                completionHandler(UIBackgroundFetchResultNewData);
            }
            else
            {
                int number;
                [UIApplication sharedApplication].applicationIconBadgeNumber = number;
                completionHandler(UIBackgroundFetchResultNoData);
            }
        }

    }];
    
}


#pragma mark - Push Notification Registration

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	TTLog(@"Device token is: %@", deviceToken);
    [[TaloolFrameworkHelper sharedInstance] setApnDeviceToken:deviceToken];
    
    [Crashlytics setUserIdentifier:[NSString stringWithFormat:@"%@",deviceToken]];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	TTLog(@"Failed to get token, error: %@", error);
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    self.isNavigating = NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isNavigating = YES;
}

#pragma mark -
#pragma mark - NotificationCenter methods

- (void) handleUserLogin:(NSNotification *)message
{
    [[self managedObjectContext] reset];
}


#pragma mark -
#pragma mark - TestFlight - Exception Handlers

/*
My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
*/
void HandleExceptions(NSException *exception) {
    [TestFlight passCheckpoint:@"CRASH"];
    // Save application data on crash
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 */
void SignalHandler(int sig) {
    [TestFlight passCheckpoint:@"SIGNAL"];
    // Save application data on crash
}


@end
