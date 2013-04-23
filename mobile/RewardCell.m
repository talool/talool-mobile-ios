//
//  RewardCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RewardCell.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"

@implementation RewardCell

@synthesize deal;

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    dateLabel.backgroundColor = backgroundColor;
    redeemedView.backgroundColor = backgroundColor;
}

- (void)setIcon:(UIImage *)newIcon
{
    iconView.image = newIcon;
}

- (void)setName:(NSString *)newName
{
    if ([deal hasBeenRedeemed]) {
        NSDictionary* attributes = @{
                                     NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     };
        
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:newName attributes:attributes];
        nameLabel.attributedText = attrText;
    } else {
        nameLabel.text = newName;
    }
}

- (void)setDate:(NSString *)newDate
{
    dateLabel.text = newDate;
}

- (void)setDeal:(ttDealAcquire *)newDeal
{
    deal = newDeal;
    [self setName:newDeal.deal.title];
    NSString *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    if ([deal hasBeenRedeemed]) {
        date = [NSString stringWithFormat:@"Redeemed on %@", [dateFormatter stringFromDate:deal.redeemed]];
        [self setIcon:[UIImage imageNamed:@"Icon_tan.png"]];
        
    } else {
        date = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:deal.deal.expires]];
        [self setIcon:[UIImage imageNamed:@"Icon_teal.png"]];
    }
    [self setDate:date];
}

@end
