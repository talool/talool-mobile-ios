//
//  TaloolTabBarController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolTabBarController.h"
#import "TaloolColor.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "OperationQueueManager.h"
#import "CustomerHelper.h"
#import <AppDelegate.h>

@implementation TaloolTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the color fo the tabBar
    self.tabBar.barTintColor = [TaloolColor true_dark_gray];
    self.tabBar.selectedImageTintColor = [UIColor whiteColor];
    
    // Set the icon for MyDeals
    UITabBarItem *mydeals = [self.tabBar.items objectAtIndex:0];
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:29];
    UIImage *mydealsIcon = [userIcon imageWithSize:CGSizeMake(30, 30)];
    
    mydeals.image = mydealsIcon;
    mydeals.title = @"My Deals";
    
    // Set the icon for Find Deals
    UITabBarItem *explore = [self.tabBar.items objectAtIndex:1];
    FAKFontAwesome *searchIcon = [FAKFontAwesome searchIconWithSize:29];
    UIImage *tabBarIcon = [searchIcon imageWithSize:CGSizeMake(30, 30)];
    
    explore.image = tabBarIcon;
    explore.title = @"Find Deals";
    
    // Set the icon for Activity
    UITabBarItem *activity = [self.tabBar.items objectAtIndex:2];
    FAKFontAwesome *timeIcon = [FAKFontAwesome clockOIconWithSize:29];
    UIImage *activityIcon = [timeIcon imageWithSize:CGSizeMake(30, 30)];
                             
    activity.image = activityIcon;
    activity.title = @"Activity";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLogout)
                                                 name:LOGOUT_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleActivity:)
                                                 name:ACTIVITY_NOTIFICATION
                                               object:nil];
}

- (void) updateBadge:(NSNumber *)count
{
    NSString *badge;
    if ([count intValue] > 0)
    {
        badge = [NSString stringWithFormat:@"%@",count];
    }
    UITabBarItem *activity = [self.tabBar.items objectAtIndex:2];
    activity.badgeValue = badge;
}

- (void) handleActivity:(NSNotification *)message
{
    
    NSDictionary *dictionary = message.userInfo;
    if (dictionary)
    {
        NSNumber *openCount = [dictionary objectForKey:DELEGATE_RESPONSE_COUNT];
        if (openCount)
        {
            [self updateBadge:openCount];
        }
        else
        {
            [self updateBadge:nil];
        }
    }
}

- (void) handleUserLogout
{
    [self updateBadge:nil];
}

- (void) resetViews
{
    for (UINavigationController *c in self.viewControllers)
    {
        [c popToRootViewControllerAnimated:NO];
    }
}

@end
