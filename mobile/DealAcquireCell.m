//
//  RewardCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealAcquireCell.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"

@implementation DealAcquireCell

@synthesize deal, nameLabel, iconView, dateLabel, cellBackground, disclosureIndicator;

- (void)setIcon:(UIImage *)newIcon
{
    iconView.image = newIcon;
}

- (void)setName:(NSString *)newName
{
    nameLabel.text = newName;
}

- (void)setDate:(NSString *)newDate
{
    dateLabel.text = newDate;
}

- (void)setDeal:(ttDealAcquire *)newDeal
{
    deal = newDeal;
}

@end
