//
//  HelpNetworkFailureViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaloolUIButton;

@interface HelpNetworkFailureViewController : UIViewController

enum {
    DealsNotLoaded = 1
};
typedef int NetworkMessageType;

@property (nonatomic) NetworkMessageType messageType;
@property (strong, nonatomic) IBOutlet UIImageView *funnyImage;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet TaloolUIButton *confirmButton;
- (IBAction)confirmAction:(id)sender;



@end
