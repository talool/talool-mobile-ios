//
//  TutorialViewController.h
//  Talool
//
//  Created by Douglas McCuen on 12/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"

static NSString *WELCOME_TUTORIAL_KEY = @"WELCOME_TUTORIAL";

@interface TutorialViewController : UIViewController<EAIntroDelegate>

@property (strong, nonatomic) NSString *tutorialKey;

@end
