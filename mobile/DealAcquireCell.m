//
//  RewardCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealAcquireCell.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"

@implementation DealAcquireCell

@synthesize deal, nameLabel, iconView, dateLabel;

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    dateLabel.backgroundColor = backgroundColor;
    redeemedView.backgroundColor = backgroundColor;
}

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
