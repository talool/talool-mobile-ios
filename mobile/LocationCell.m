//
//  LocationCell.m
//  Talool
//
//  Created by Douglas McCuen on 5/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LocationCell.h"
#import "Talool-API/ttMerchantLocation.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@implementation LocationCell

@synthesize location, cellBackground;


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
    
    [self setName:location.address1];
    
    [self setIcon:[IconHelper getImageForIcon:[FAKFontAwesome mapMarkerIconWithSize:24] color:[TaloolColor orange]]];
    
    [self setAddress:[NSString stringWithFormat:@"%@, %@, %@",location.city, location.stateProvidenceCounty, location.zip]];

}

@end
