//
//  AppDelegate.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class WelcomeViewController, TaloolTabBarController, SplashViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TaloolTabBarController *mainViewController;
@property (strong, nonatomic) UINavigationController* loginViewController;
@property (strong, nonatomic) SplashViewController* splashView;
@property BOOL isNavigating;
@property BOOL isSplashing;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property NSTimeInterval minUpdateInterval;

- (NSURL *)applicationDocumentsDirectory;
- (void) presentNewDeals;
- (void) setUserAgent;
- (void) switchToMainView;
- (void) switchToLoginView;

#define GA_TRACKING_ID  @"UA-42344079-1"
#define TESTFLIGHT_APP_TOKEN @"162f2dda-dd77-461f-b04f-93add82d8af5"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@end
