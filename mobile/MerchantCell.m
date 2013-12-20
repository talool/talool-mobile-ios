//
//  ApplicationCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantCell.h"
#import "Talool-API/ttCategory.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttMerchantLocation.h"
#import "CategoryHelper.h"

@implementation MerchantCell

- (void)setMerchant:(ttMerchant *)merchant remainingDeals:(int)count
{
    ttCategory *cat = (ttCategory *)merchant.category;
    [iconView setImage:[[CategoryHelper sharedInstance] getIcon:[cat.categoryId intValue]]];
    
    [nameLabel setText:merchant.name];
    
    [addressLabel setText:[merchant getLocationLabel]];
    
    ttMerchantLocation *loc = [merchant getClosestLocation];
    if ([loc getDistanceInMiles] == nil || [[loc getDistanceInMiles] intValue]==0)
    {
        [distanceLabel setText:[NSString stringWithFormat:@"%d deals",count]];
    }
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@"###0.##"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *miles = [formatter stringFromNumber:[loc getDistanceInMiles]];
        [distanceLabel setText:[NSString stringWithFormat:@"%d deals, %@ miles away",count, miles] ];
    }
    
}

@end
