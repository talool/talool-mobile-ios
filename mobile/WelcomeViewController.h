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

@interface WelcomeViewController : UITableViewController<OperationQueueDelegate>
{
    IBOutlet TaloolUIButton *signinButton;
    IBOutlet TaloolUIButton *facebookButton;
}

@property (strong, nonatomic) ttCustomer *failedUser;

@end
