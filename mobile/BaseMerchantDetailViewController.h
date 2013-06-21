//
//  BaseMerchantDetailViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttMerchant, MerchantBannerView;

@interface BaseMerchantDetailViewController : UIViewController<MerchantBannerDelegate>
{
    ttMerchant *merchant;
}
@property (nonatomic, retain) MerchantBannerView *merchantBanner;
@property (nonatomic, retain) ttMerchant *merchant;

@end
