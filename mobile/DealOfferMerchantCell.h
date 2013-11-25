//
//  DealOfferMerchantCell.h
//  Talool
//
//  Created by Douglas McCuen on 11/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ttDeal, ttMerchant;

@interface DealOfferMerchantCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *summaryLabel;
    IBOutlet UILabel *merchantLabel;
}

- (void)setMerchant:(ttMerchant *)merchant;

@end
