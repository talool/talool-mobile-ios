//
//  ApplicationCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantCell.h"
#import "talool-api-ios/TaloolAddress.h"

@implementation MerchantCell

@synthesize merchant, icon, category, address, name;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMerchant:(ttMerchant *)newMerchant {
    if (newMerchant != merchant) {
        merchant = newMerchant;
        
        [self setIcon:[UIImage imageNamed:@"Icon_teal.png"]];
        [self setName:merchant.name];
        [self setCategory:@"Fine Dining"];
        [self setAddress:[merchant getLocationLabel]];

    }
}

- (ttMerchant *)merchant {
    return merchant;
}


@end
