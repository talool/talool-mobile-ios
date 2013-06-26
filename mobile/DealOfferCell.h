//
//  DealOfferCell.h
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealOffer, TaloolUIButton;

@interface DealOfferCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *merchantLabel;
    
    ttDealOffer *offer;
    
}

@property (nonatomic, retain) ttDealOffer *offer;

- (void)setDealOffer:(ttDealOffer *)dealOffer;


@end
