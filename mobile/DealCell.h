//
//  DealCell.h
//  Talool
//
//  Created by Douglas McCuen on 6/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDeal, ttMerchant;

@interface DealCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *summaryLabel;
    IBOutlet UILabel *merchantLabel;
}


@property (retain, nonatomic) UILabel *summaryLabel;
@property (retain, nonatomic) UIImageView *iconView;
@property (retain, nonatomic) UILabel *merchantLabel;

- (void)setMerchant:(ttMerchant *)merchant;
- (void)setDeal:(ttDeal *)deal;

@end
