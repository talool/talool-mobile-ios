//
//  OfferMapCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferMapCell.h"
#import "talool-api-ios/ttDealOffer.h"

@implementation OfferMapCell

@synthesize offer, mapLabel, mapView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setOffer:(ttDealOffer *)dealOffer
{
    offer = dealOffer;
    mapLabel.text = [NSString stringWithFormat:@"%d deals from %d merchants in the %@ area",10,4,offer.locationName];
    // TODO configure the cell
}

@end
