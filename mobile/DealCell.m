//
//  DealCell.m
//  Talool
//
//  Created by Douglas McCuen on 6/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealCell.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttCategory.h"
#import "CategoryHelper.h"

@implementation DealCell

@synthesize summaryLabel, merchantLabel, iconView;

- (void)setDeal:(ttDeal *)deal
{
    summaryLabel.text = deal.merchant.name;
    merchantLabel.text = [deal.merchant getLocationLabel];
    
    ttCategory *cat = (ttCategory *)deal.merchant.category;
    iconView.image =[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]];
}

- (void)setMerchant:(ttMerchant *)merchant
{
    summaryLabel.text = merchant.name;
    merchantLabel.text = [merchant getLocationLabel];
    
    ttCategory *cat = (ttCategory *)merchant.category;
    iconView.image =[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]];
}

@end
