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

@implementation TaloolTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the color fo the tabBar
    //self.tabBar.barTintColor = [TaloolColor gray_5];
    //self.tabBar.selectedImageTintColor = [TaloolColor teal];
    
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

    
}


@end
