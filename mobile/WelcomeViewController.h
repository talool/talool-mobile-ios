//
//  WelcomeViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@interface WelcomeViewController : UIViewController<FBLoginViewDelegate>

- (IBAction)logoutAction:(UIStoryboardSegue *)segue;

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;

@end
