//
//  ApplicationCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantCell.h"
#import "Talool-API/ttCategory.h"
#import "Talool-API/ttMerchantLocation.h"
#import "CategoryHelper.h"

@implementation MerchantCell

- (void)setMerchant:(ttMerchant *)merchant
{
    ttCategory *cat = (ttCategory *)merchant.category;
    [iconView setImage:[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]]];
    
    [nameLabel setText:merchant.name];
    
    [addressLabel setText:[merchant getLocationLabel]];
    
    ttMerchantLocation *loc = [merchant getClosestLocation];
    if ([loc getDistanceInMiles] == nil || [[loc getDistanceInMiles] intValue]==0)
    {
        [distanceLabel setText:@"  "];
    }
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@"###0.##"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *miles = [formatter stringFromNumber:[loc getDistanceInMiles]];
        [distanceLabel setText:[NSString stringWithFormat:@"%@ miles",miles] ];
    }
}


@end
