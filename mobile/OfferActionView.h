//
//  OfferActionView.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, ttDealOffer;

@interface OfferActionView : UIView
{
    IBOutlet UIView *view;
}
@property (strong, nonatomic) IBOutlet TaloolUIButton *buyButton;
@property id<DealOfferPurchaseDelegate> delegate;
@property (strong, nonatomic) ttDealOffer *offer;

- (IBAction)buyAction:(id)sender;

- (id)initWithFrame:(CGRect)frame offer:(ttDealOffer *)offer;

@end
