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
    categoryLabel.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    //ratingView.backgroundColor = backgroundColor;
    //numRatingsLabel.backgroundColor = backgroundColor;
    pointsLabel.backgroundColor = backgroundColor;
    visitsLabel.backgroundColor = backgroundColor;
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

- (void)setPoints:(NSString *)newPoints
{
    [super setPoints:newPoints];
    pointsLabel.text = newPoints;
}

- (void)setVisits:(NSString *)newVisits
{
    [super setVisits:newVisits];
    visitsLabel.text = newVisits;
}

@end
