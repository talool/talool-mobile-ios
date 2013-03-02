//
//  ApplicationCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantCell.h"

@implementation MerchantCell

@synthesize useDarkBackground, merchant, icon, category, name, points, talools, visits;

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

- (void)setUseDarkBackground:(BOOL)flag
{
    if (flag != useDarkBackground || !self.backgroundView)
    {
        useDarkBackground = flag;
        
        //NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
        //UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        //self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        //self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.backgroundView.frame = self.bounds;
    }
}

- (void)setMerchant:(TaloolMerchant *)newMerchant {
    if (newMerchant != merchant) {
        merchant = newMerchant;
        
        //self.icon = merchant.thumbnailImage;
        self.name = merchant.name;
        //self.category = merchant.category;
        //self.points = merchant.points;
        //self.talools = merchant.talools;
        //self.visits = merchant.visits;
    }
}

- (TaloolMerchant *)merchant {
    return merchant;
}


@end
