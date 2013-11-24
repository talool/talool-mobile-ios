//
//  OfferMerchantView.h
//  Talool
//
//  Created by Douglas McCuen on 11/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealOffer, ttMerchant;

@interface OfferMerchantView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UIImageView *dealOfferImage;
    IBOutlet UIImageView *publisherLogo;
    IBOutlet UIImageView *merchantLogo;
    IBOutlet UILabel *summaryLabel;
}

@property (strong, nonatomic) ttDealOffer *offer;
@property (strong, nonatomic) ttMerchant *merchant;

-(void) updateView:(ttDealOffer *)newOffer merchant:(ttMerchant *)merch;

@end
