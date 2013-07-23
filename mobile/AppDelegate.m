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
#import "talool-api-ios/TaloolPersistentStoreCoordinator.h"
#import "talool-api-ios/ttActivity.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "TaloolColor.h"
#import "TaloolIAPHelper.h"
#import "TaloolTabBarController.h"
#import "WelcomeViewController.h"
#import "SettingsTableViewController.h"
#import "MyDealsViewController.h"
#import "ActivityViewController.h"
#import "ActivityStreamHelper.h"
#import "DealOfferHelper.h"
#import "MerchantSearchView.h"
#import "SplashViewController.h"
#import "talool-api-ios/GAI.h"

@implementation AppDelegate

@synthesize window = _window,
            navigationController = _navigationController,
            mainViewController = _mainViewController,
            loginViewController = _loginViewController,
            isNavigating = _isNavigating;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize settingsViewController = _settingsViewController;
@synthesize firstViewController = _firstViewController;
@synthesize activiyViewController = _activiyViewController;
@synthesize activityHelper, splashView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    self.splashView = [storyboard instantiateViewControllerWithIdentifier:@"SplashView"];
    [self.window addSubview:self.splashView.view];
    [self.window makeKeyAndVisible];
    
    [NSThread detachNewThreadSelector:@selector(setupApp) toTarget:self withObject:nil];
    
    return YES;
}

- (void) setupApp
{
    [CustomerHelper setContext:self.managedObjectContext];
    [FacebookHelper setContext:self.managedObjectContext];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    self.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    //self.mainViewController.navigationItem.hidesBackButton = YES;
    
    // Add the view controller for My Deals
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    UINavigationController *navController;
    self.firstViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyDeals"];
    navController = [[UINavigationController alloc]
                     initWithRootViewController:self.firstViewController];
    navController.delegate = self;
    [navController.navigationBar setTintColor:[TaloolColor teal]];
    [navController.navigationBar setBarStyle:UIBarStyleBlack];
    [viewControllers addObject:navController];
    
    // Add the view controller for Find Deals
    navController = [[UINavigationController alloc]
                     initWithRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"FindDeals1"]];
    navController.delegate = self;
    [navController.navigationBar setTintColor:[TaloolColor teal]];
    [navController.navigationBar setBarStyle:UIBarStyleBlack];
    [viewControllers addObject:navController];
    
    // Add the view controller for Activity
    self.activiyViewController = [storyboard instantiateViewControllerWithIdentifier:@"Activity"];
    navController = [[UINavigationController alloc]
                     initWithRootViewController:self.activiyViewController];
    navController.delegate = self;
    [navController.navigationBar setTintColor:[TaloolColor teal]];
    [navController.navigationBar setBarStyle:UIBarStyleBlack];
    [viewControllers addObject:navController];
    
    [self.mainViewController setViewControllers:viewControllers];
    
    [TaloolIAPHelper sharedInstance];
    [DealOfferHelper sharedInstance];
    
    activityHelper = [[ActivityStreamHelper alloc] initWithDelegate:self];
    
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKING_ID];
    
    [self performSelectorOnMainThread:@selector(finalizeSetup) withObject:nil waitUntilDone:NO];
    
}

- (void) finalizeSetup
{
    [self.splashView.view removeFromSuperview];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if (!url || ![url absoluteString]) {
        return NO;
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
            if ([FBSession activeSession].isOpen) {
                NSLog(@"INFO: Ignoring app link because current session is open.");
            } else {
                [self handleAppLink:appLinkToken];
                return YES;
            }
        }
    }
    return NO;
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
    
    NSString *message = [NSString stringWithFormat:@"The application received a request to open this URL: %@. Be careful when servicing handleOpenURL requests!", URLString];
    
    UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:@"handleOpenURL:" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [openURLAlert show];
    
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
    [activityHelper stopPollingActivity];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActive];
    [activityHelper startPollingActivity];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
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
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                  NSLog(@"FB login error %@",error);
                                  [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}

#pragma mark - 
#pragma mark - IAP Helpers 

- (void)productPurchased:(NSNotification *)notification
{
    
    ttDealOffer *offer = [[TaloolIAPHelper sharedInstance] getOfferForIdentifier:notification.object];
    
    NSError *err;
    BOOL success = [[CustomerHelper getLoggedInUser] purchaseDealOffer:offer error:&err];
    if (success)
    {
        [self presentNewDeals];
    }
    else
    {
        // TODO handle failure.  The user has purchased, but we haven't delivered the deals.
        // * Store the offer in the user's NSUserDefaults and retry later
    }
}

-(void) presentNewDeals
{
    // refresh the deals
    [self.firstViewController.searchView fetchMerchants];
    
    if (self.mainViewController.selectedViewController != self.firstViewController)
    {
        // the user is on FindDeals or Activity, so we should ask if they want to be redirected
        UIAlertView *showMe = [[UIAlertView alloc] initWithTitle:@"You've Got Deals!"
                                                            message:@"We've updated your account with new deals.  Would you like to see them now?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Yes"
                                                  otherButtonTitles:@"No",nil];
        [showMe show];
        
    }

}

#pragma mark - UIAlertViewDelegate 

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
    {
        // take the user to the "my deals" tab
        [self.mainViewController setSelectedIndex:0];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"mobile.sqlite"];
    _persistentStoreCoordinator = [TaloolPersistentStoreCoordinator initWithStoreUrl:storeURL];
        
    return _persistentStoreCoordinator;
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
#pragma mark - ActivityStreamDelegate methods

- (void)activitySetChanged:(NSArray *)newActivies sender:(id)sender
{
    
}
- (void)openActivityCountChanged:(int)count sender:(id)sender
{
    NSString *badge;
    if (count > 0)
    {
        badge = [NSString stringWithFormat:@"%d",count];
    }
    [[self.activiyViewController navigationController] tabBarItem].badgeValue = badge;
}

@end
