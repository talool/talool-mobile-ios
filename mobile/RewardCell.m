//
//  RewardCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RewardCell.h"

@implementation RewardCell

@synthesize deal;

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    pointsLabel.backgroundColor = backgroundColor;
}

- (void)setIcon:(UIImage *)newIcon
{
    iconView.image = newIcon;
}

- (void)setName:(NSString *)newName
{
    nameLabel.text = newName;
}

- (void)setPoints:(NSString *)newPoints
{
    pointsLabel.text = newPoints;
}

- (void)setDeal:(ttCoupon *)newDeal
{
    deal = newDeal;
    [self setName:newDeal.name];
}

@end
