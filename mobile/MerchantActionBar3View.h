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
    
    IBOutlet UILabel *webLabel;
    IBOutlet UILabel *callLabel;
    IBOutlet UILabel *mapLabel;
    IBOutlet UIImageView *webIcon;
    IBOutlet UIImageView *callIcon;
    IBOutlet UIImageView *mapIcon;
}

- (IBAction)mapAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)webAction:(id)sender;

@property (nonatomic, strong) id<TaloolMerchantActionDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<TaloolMerchantActionDelegate>)actionDelegate;

@end