//
//  MerchantCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FavoriteMerchantCell.h"

@implementation FavoriteMerchantCell

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = backgroundColor;
    publisherLabel.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    //ratingView.backgroundColor = backgroundColor;
    //numRatingsLabel.backgroundColor = backgroundColor;
    priceLabel.backgroundColor = backgroundColor;
}

- (void)setIcon:(UIImage *)newIcon
{
    [super setIcon:newIcon];
    iconView.image = newIcon;
}

- (void)setPublisher:(NSString *)newPublisher
{
    [super setPublisher:newPublisher];
    publisherLabel.text = newPublisher;
}
/*
- (void)setRating:(float)newRating
{
    [super setRating:newRating];
    ratingView.rating = newRating;
}

- (void)setNumRatings:(NSInteger)newNumRatings
{
    [super setNumRatings:newNumRatings];
    numRatingsLabel.text = [NSString stringWithFormat:@"%d Ratings", newNumRatings];
}
*/
- (void)setName:(NSString *)newName
{
    [super setName:newName];
    nameLabel.text = newName;
}

- (void)setPrice:(NSString *)newPrice
{
    [super setPrice:newPrice];
    priceLabel.text = newPrice;
}

@end
