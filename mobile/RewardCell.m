//
//  RewardCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RewardCell.h"

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
    if ([deal.redeemed intValue] == 1) {
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

- (void)setDeal:(ttDeal *)newDeal
{
    deal = newDeal;
    [self setName:newDeal.title];
    NSString *date;
    NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    if ([deal.redeemed intValue] == 1) {
        // TODO add the right date
        date = [NSString stringWithFormat:@"Redeemed on %@", [dateFormatter stringFromDate:today]];
        [self setIcon:[UIImage imageNamed:@"Icon_tan.png"]];
        
    } else {
        // TODO add the right date
        date = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:today]];
        [self setIcon:[UIImage imageNamed:@"Icon_teal.png"]];
    }
    [self setDate:date];
}

@end
