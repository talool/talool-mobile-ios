//
//  LocationCell.m
//  Talool
//
//  Created by Douglas McCuen on 5/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LocationCell.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttAddress.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"

@implementation LocationCell

@synthesize location;

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    addressLabel.backgroundColor = backgroundColor;
}

- (void)setIcon:(UIImage *)newIcon
{
    iconView.image = newIcon;
}

- (void)setName:(NSString *)newName
{
    nameLabel.text = newName;
}

- (void)setAddress:(NSString *)address
{
    addressLabel.text = address;
}

- (void)setLocation:(ttMerchantLocation *)newLocation
{
    location = newLocation;
    
    [self setName:location.address.address1];
    
    [self setIcon:[IconHelper getImageForIcon:FAKIconMapMarker color:[TaloolColor orange]]];
    
    [self setAddress:[NSString stringWithFormat:@"%@, %@, %@",location.address.city, location.address.stateProvidenceCounty, location.address.zip]];

}

@end
