//
//  ApplicationCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantCell.h"
#import "talool-api-ios/TaloolAddress.h"
#import "talool-api-ios/ttCategory.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "CategoryHelper.h"

@implementation MerchantCell

@synthesize merchant, icon, distance, address, name;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMerchant:(ttMerchant *)newMerchant {
    if (newMerchant != merchant) {
        merchant = newMerchant;
        ttCategory *cat = (ttCategory *)newMerchant.category;
        ttMerchantLocation *loc = [newMerchant getClosestLocation];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setPositiveFormat:@"###0.##"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *miles = [formatter stringFromNumber:[loc getDistanceInMiles]];
        
        [self setIcon:[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]]];
        [self setName:merchant.name];
        
        if (miles>0)
        {
            [self setDistance: [NSString stringWithFormat:@"%@ miles",miles] ];
        }
        else
        {
            [self setDistance: @"" ];
        }
        
        [self setAddress:[merchant getLocationLabel]];

    }
}

- (ttMerchant *)merchant {
    return merchant;
}


@end
