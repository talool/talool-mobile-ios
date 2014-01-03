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
    
   
    NSString *countLabel = [self getDealCountLabel:count];
    NSString *milesLabel = [self getDistanceLabel:[[merchant getClosestLocation] getDistanceInMiles]];
    if (countLabel && milesLabel)
    {
        [distanceLabel setText:[NSString stringWithFormat:@"%@, %@",countLabel, milesLabel]];
    }
    else if (countLabel)
    {
        [distanceLabel setText:countLabel];
    }
    else if (milesLabel)
    {
        [distanceLabel setText:milesLabel];
    }
    
}

- (NSString *) getDealCountLabel:(int)count
{
    NSString *label;
    
    if (count && count > 0)
    {
        NSString *dealLabel = (count==1)?@"deal":@"deals";
        label = [NSString stringWithFormat:@"%d %@",count, dealLabel];
    }
    
    return label;
}

- (NSString *) getDistanceLabel:(NSNumber *)miles
{
    NSString *label;
    
    if (miles && [miles intValue] > 0)
    {
        if ([miles intValue] > 100)
        {
            label = @"far, far away";
        }
        else
        {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setPositiveFormat:@"###0.##"];
            [formatter setLocale:[NSLocale currentLocale]];
            NSString *m = [formatter stringFromNumber:miles];
            label = [NSString stringWithFormat:@"%@ miles away",m];
        }
    }
    
    return label;
}

@end
