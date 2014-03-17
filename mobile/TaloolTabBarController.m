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

@implementation TaloolTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the color fo the tabBar
    self.tabBar.barTintColor = [TaloolColor true_dark_gray];
    
    // Set the icon for MyDeals
    UITabBarItem *mydeals = [self.tabBar.items objectAtIndex:0];
    UIImage *mydealsIcon = [FontAwesomeKit imageForIcon:FAKIconUser
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    mydeals.image = mydealsIcon;
    mydeals.title = @"My Deals";
    
    // Set the icon for Find Deals
    UITabBarItem *explore = [self.tabBar.items objectAtIndex:1];
    UIImage *tabBarIcon = [FontAwesomeKit imageForIcon:FAKIconSearch
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    explore.image = tabBarIcon;
    explore.title = @"Find Deals";
    
    // Set the icon for Activity
    UITabBarItem *activity = [self.tabBar.items objectAtIndex:2];
    UIImage *activityIcon = [FontAwesomeKit imageForIcon:FAKIconTime
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    activity.image = activityIcon;
    activity.title = @"Activity";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleActivity:)
                                                 name:LOGIN_NOTIFICATION
                                               object:nil];
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

@end
