//
//  DealOfferMerchantCell.m
//  Talool
//
//  Created by Douglas McCuen on 11/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferMerchantCell.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttCategory.h"
#import "CategoryHelper.h"

@implementation DealOfferMerchantCell

- (void)setMerchant:(ttMerchant *)merchant
{
    summaryLabel.text = merchant.name;
    merchantLabel.text = [merchant getLocationLabel];
    
    ttCategory *cat = (ttCategory *)merchant.category;
    iconView.image =[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]];
}

@end
