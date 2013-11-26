//
//  OfferSummaryView.h
//  Talool
//
//  Created by Douglas McCuen on 11/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealOffer;

@interface OfferSummaryView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UIImageView *dealOfferImage;
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *summaryLabel;
}

@property (strong, nonatomic) ttDealOffer *offer;

-(void) updateOffer:(ttDealOffer *)newOffer;

@end
