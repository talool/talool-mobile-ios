//
//  OfferActionView.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class ttDealOffer;

@interface OfferActionView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UIImageView *dealOfferImage;
    IBOutlet UILabel *priceLabel;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *buyButton;
    IBOutlet UIBarButtonItem *activateButton;
    IBOutlet UILabel *summaryLabel;
}
@property (strong, nonatomic) ttDealOffer *offer;

- (IBAction)buyAction:(id)sender;
- (IBAction)activateAction:(id)sender;

-(void) updateOffer:(ttDealOffer *)newOffer;

- (id)initWithFrame:(CGRect)frame delegate:(id<TaloolDealOfferActionDelegate>)delegate;

@end
