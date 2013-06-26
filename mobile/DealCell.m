//
//  DealCell.m
//  Talool
//
//  Created by Douglas McCuen on 6/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealCell.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttCategory.h"
#import "CategoryHelper.h"

@implementation DealCell

@synthesize deal, summaryLabel, merchantLabel, iconView;

- (void)setDeal:(ttDeal *)newDeal
{
    deal = newDeal;
    summaryLabel.text = deal.title;
    merchantLabel.text = deal.merchant.name;
    
    ttCategory *cat = (ttCategory *)deal.merchant.category;
    CategoryHelper *helper = [[CategoryHelper alloc] init];
    iconView.image =[helper getIcon:[cat.categoryId intValue]];
}

@end
