//
//  ApplicationCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ApplicationCell.h"

@implementation ApplicationCell

@synthesize useDarkBackground, merchant, icon, publisher, name, price;

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
        
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}

- (void)setMerchant:(Merchant *)newMerchant {
    if (newMerchant != merchant) {
        merchant = newMerchant;
        
        self.icon = merchant.thumbnailImage;
        self.name = merchant.name;
        self.publisher = merchant.publisher;
        self.price = merchant.price;
    }
}

- (Merchant *)merchant {
    return merchant;
}


@end
