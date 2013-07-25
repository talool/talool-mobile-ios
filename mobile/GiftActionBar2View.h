//
//  GiftActionBar2View.h
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttGift;

@interface GiftActionBar2View : UIView
{
    IBOutlet UIView *view;
    
    IBOutlet UIView *inactiveView;
    IBOutlet UIView *twoButtonView;
    
    IBOutlet UILabel *message;
    
    IBOutlet UILabel *rejectLabel;
    IBOutlet UILabel *acceptLabel;
    IBOutlet UIImageView *acceptIcon;
    IBOutlet UIImageView *rejectIcon;
}

- (id)initWithFrame:(CGRect)frame gift:(ttGift *)gift delegate:(id<TaloolGiftActionDelegate>)actionDelegate;
- (void) updateView:(ttGift *)gift;
- (IBAction)rejectGift:(id)sender;
- (IBAction)acceptGift:(id)sender;

@property (nonatomic, strong) id<TaloolGiftActionDelegate> delegate;

@end
