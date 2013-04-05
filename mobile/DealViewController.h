//
//  DataViewController.h
//  PageTurner
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttDeal;

@interface DealViewController : UIViewController<FBFriendPickerDelegate,UIAlertViewDelegate> {
    
}

- (IBAction)shareAction:(id)sender;
- (IBAction)redeemAction:(id)sender;

@property (nonatomic, retain) IBOutlet UIImageView *qrCode;
@property (nonatomic, retain) IBOutlet UIImageView *prettyPicture;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IBOutlet UILabel *expiresLabel;

@property (strong, nonatomic) ttDeal *coupon;

@end
