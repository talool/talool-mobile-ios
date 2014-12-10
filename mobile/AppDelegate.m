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
#import "Talool-API/ttCustomer.h"
#import "TaloolTabBarController.h"
#import "WelcomeViewController.h"
#import "SplashViewController.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "TaloolAppCall.h"
#import <OperationQueueManager.h>
#import "LocationHelper.h"
#import "CustomerHelper.h"
#import "WhiteLabelHelper.h"
#import "ActivityOperation.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize window = _window,
            navigationController = _navigationController,
            isNavigating = _isNavigating,
            isSplashing = _isSplashing;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    #warning @"Environment set to dev"
    [[TaloolFrameworkHelper sharedInstance] setEnvironment:EnvironmentTypeDevelopment];

    [Crashlytics startWithAPIKey:@"621dd92cb7c068e9486411b53478071c2c3f5357"];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.isSplashing = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    _navigationController = [storyboard instantiateViewControllerWithIdentifier:@"splash_nav"];
    [self.window addSubview:_navigationController.view];
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:_navigationController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogin:)
                                                 name:LOGIN_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogin:)
                                                 name:REG_NOTIFICATION
                                               object:nil];
    
    
    return YES;
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
    
    NSLog(@"UserAgent appVersion: %@ iOSVersion: %@", appVersion, iosVersion);
    
    [[TaloolFrameworkHelper sharedInstance] setUserAgent:appVersion iosVersion:iosVersion];
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
    [self setUserAgent];
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
	NSLog(@"Device token is: %@", deviceToken);
    [[TaloolFrameworkHelper sharedInstance] setApnDeviceToken:deviceToken];
    
    [Crashlytics setUserIdentifier:[NSString stringWithFormat:@"%@",deviceToken]];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
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
    
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    [Crashlytics setUserEmail:[NSString stringWithFormat:@"%@",customer.email]];
    [Crashlytics setUserName:[NSString stringWithFormat:@"%@ %@",customer.firstName, customer.lastName]];
}


@end
