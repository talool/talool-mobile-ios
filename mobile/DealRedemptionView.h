//
//  DealRedemptionView.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttDealAcquire, TaloolUIButton;

@interface DealRedemptionView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UILabel *message;
    IBOutlet TaloolUIButton *redeemButton;
}
@property (strong, nonatomic) id<TaloolDealActionDelegate> delegate;

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcquire delegate:(id<TaloolDealActionDelegate>)actionDelegate;
- (IBAction)redeemAction:(id)sender;
- (void) updateView:(ttDealAcquire *)dealAcquire;

@end
