//
//  AppDelegate.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class WelcomeViewController, TaloolTabBarController, SettingsTableViewController, MyDealsViewController, ActivityViewController, ActivityStreamHelper, SplashViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, ActivityStreamDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TaloolTabBarController *mainViewController;
@property (strong, nonatomic) WelcomeViewController* loginViewController;
@property (strong, nonatomic) SettingsTableViewController* settingsViewController;
@property (strong, nonatomic) ActivityViewController* activiyViewController;
@property (strong, nonatomic) MyDealsViewController* firstViewController;
@property (strong, nonatomic) SplashViewController* splashView;
@property (strong, nonatomic) ActivityStreamHelper* activityHelper;
@property BOOL isNavigating;
@property BOOL isSplashing;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void) presentNewDeals;

#define GA_TRACKING_ID  @"UA-42344079-1"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@end
