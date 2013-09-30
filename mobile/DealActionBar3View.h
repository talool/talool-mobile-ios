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
    
    IBOutlet UILabel *message;
    IBOutlet UIImageView *dealImage;
    
    IBOutlet UIBarButtonItem *redeemButton;
    IBOutlet UIBarButtonItem *emailButton;
}
- (IBAction)redeemAction:(id)sender;
- (IBAction)giftAction:(id)sender;

@property (nonatomic, strong) id<TaloolDealActionDelegate> delegate;

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcquire delegate:(id<TaloolDealActionDelegate>)actionDelegate;
- (void) updateView:(ttDealAcquire *)dealAcquire;

@end
