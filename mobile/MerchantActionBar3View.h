//
//  MerchantActionBar3View.h
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttMerchant;

@interface MerchantActionBar3View : UIView
{
    IBOutlet UIView *view;
    IBOutlet UIImageView *image;
    IBOutlet UIBarButtonItem *mapButton;
    IBOutlet UIBarButtonItem *callButton;
    IBOutlet UIBarButtonItem *webButton;
}

- (IBAction)mapAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)webAction:(id)sender;

@property (nonatomic, strong) id<TaloolMerchantActionDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<TaloolMerchantActionDelegate>)actionDelegate;
- (void)setMerchant:(ttMerchant *)merchant;

@end