//
//  AppDelegate.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WelcomeViewController, TaloolTabBarController, SettingsTableViewController, MyDealsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TaloolTabBarController *mainViewController;
@property (strong, nonatomic) WelcomeViewController* loginViewController;
@property (strong, nonatomic) SettingsTableViewController* settingsViewController;
@property (strong, nonatomic) MyDealsViewController* firstViewController;
@property BOOL isNavigating;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;


@end
