//
//  DealActionBar3View.h
//  Talool
//
//  Created by Douglas McCuen on 7/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttDealAcquire;

@interface DealActionBar3View : UIView
{
    IBOutlet UIView *view;
    
    IBOutlet UIView *inactiveView;
    IBOutlet UIView *twoButtonView;
    IBOutlet UIView *threeButtonView;
    
    IBOutlet UILabel *message;
    
    IBOutlet UILabel *redeemLabel;
    IBOutlet UIImageView *redeemIcon;
    IBOutlet UILabel *redeemLabel2;
    IBOutlet UIImageView *redeemIcon2;
    
    IBOutlet UILabel *facebookLabel;
    IBOutlet UIImageView *facebookIcon;
    
    IBOutlet UILabel *emailLabel;
    IBOutlet UIImageView *emailIcon;
    IBOutlet UILabel *emailLabel2;
    IBOutlet UIImageView *emailIcon2;
}
- (IBAction)redeemAction:(id)sender;
- (IBAction)facebookAction:(id)sender;
- (IBAction)emailAction:(id)sender;

@property (nonatomic, strong) id<TaloolDealActionDelegate> delegate;

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcquire delegate:(id<TaloolDealActionDelegate>)actionDelegate;
- (void) updateView:(ttDealAcquire *)dealAcquire;

@end
