//
//  DealOfferCell.m
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferCell.h"
#import "TaloolColor.h"
#import "TaloolUIButton.h"
#import "CategoryHelper.h"
#import "talool-api-ios/ttDealOffer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DealOfferCell

@synthesize offer;

- (void)setDealOffer:(ttDealOffer *)dealOffer
{
    offer = dealOffer;
    
    [nameLabel setTextColor:[TaloolColor gray_5]];
    nameLabel.text = offer.title;
    
    [priceLabel setTextColor:[UIColor whiteColor]];
    if ([offer.price intValue] == 0)
    {
        priceLabel.text = @"Free";
        [iconView setImage:[CategoryHelper getCircleWithColor:[TaloolColor orange] diameter:50.0]];
    }
    else
    {
        priceLabel.text = [[NSString alloc] initWithFormat:@"$%@", offer.price];
        [iconView setImage:[CategoryHelper getCircleWithColor:[TaloolColor teal] diameter:50.0]];
    }
    
    
}

@end
