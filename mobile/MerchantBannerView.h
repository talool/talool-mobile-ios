//
//  MerchantBannerView.h
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttMerchant;

@interface MerchantBannerView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UIButton *likeButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIImageView *texture;
    IBOutlet UIImageView *logo;
    id <MerchantBannerDelegate> delegate;
}

@property (retain, nonatomic) ttMerchant *merchant;
@property (retain) id<MerchantBannerDelegate> delegate;

- (IBAction)likeAction:(id)sender;
- (IBAction)mapAction:(id)sender;

- (id)initWithMerchant:(ttMerchant *)merch frame:(CGRect)frame;

@end
