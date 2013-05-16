//
//  MerchantCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FavoriteMerchantCell.h"

@implementation FavoriteMerchantCell

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (void)setIcon:(UIImage *)newIcon
{
    [super setIcon:newIcon];
    iconView.image = newIcon;
}

- (void)setCategory:(NSString *)newCategory
{
    [super setCategory:newCategory];
    categoryLabel.text = newCategory;
}

- (void)setName:(NSString *)newName
{
    [super setName:newName];
    nameLabel.text = newName;
}

- (void)setAddress:(NSString *)newAddress
{
    [super setAddress:newAddress];
    addressLabel.text = newAddress;
}


@end
