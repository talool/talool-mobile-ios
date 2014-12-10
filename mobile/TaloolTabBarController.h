//
//  TaloolTabBarController.h
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyDealsViewController, ActivityViewController;

@interface TaloolTabBarController : UITabBarController

@property (strong, nonatomic) MyDealsViewController *myDealsView;
@property (strong, nonatomic) ActivityViewController *activityView;

- (void) resetViews;

@end
