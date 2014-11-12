//
//  RewardCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealAcquireCell.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@implementation DealAcquireCell

@synthesize deal, nameLabel, iconView, dateLabel;

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
    NSString *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy"];
    if ([deal hasBeenRedeemed])
    {
        date = [NSString stringWithFormat:@"Redeemed on %@", [dateFormatter stringFromDate:deal.redeemed]];
        
    }
    else if ([deal hasBeenShared])
    {
        if (deal.shared == nil)
        {
            date = @"Shared";
        }
        else
        {
            date = [NSString stringWithFormat:@"Shared on %@", [dateFormatter stringFromDate:deal.shared]];
        }
        
    }
    else if ([deal hasExpired])
    {
        date = [NSString stringWithFormat:@"Expired on %@", [dateFormatter stringFromDate:deal.deal.expires]];
    }
    
    NSDictionary* strikethrough = @{
                                    NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                    };
    NSDictionary* normaltext = @{};
    
    NSString *dealTitle = deal.deal.title;
    
    if ([deal hasBeenRedeemed] || [deal hasBeenShared] || [deal hasExpired])
    {
        self.iconView.image = [IconHelper getImageForIcon:[FAKFontAwesome moneyIconWithSize:24] color:[TaloolColor gray_1]];
        
        self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:dealTitle attributes:strikethrough];
    }
    else
    {
        if (deal.deal.expires ==  nil)
        {
            date = @"Never Expires";
        }
        else
        {
            date = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:deal.deal.expires]];
        }
        self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:dealTitle attributes:normaltext];
        self.iconView.image = [IconHelper getImageForIcon:[FAKFontAwesome moneyIconWithSize:24] color:[TaloolColor green]];
    }
    
    self.dateLabel.text = date;
    
}

@end
