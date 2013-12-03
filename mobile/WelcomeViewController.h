//
//  WelcomeViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TaloolProtocols.h"

@class TaloolUIButton, ttCustomer;

@interface WelcomeViewController : UITableViewController<FBLoginViewDelegate, OperationQueueDelegate>
{
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet TaloolUIButton *signinButton;
}

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;
@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) ttCustomer *failedUser;

@end
