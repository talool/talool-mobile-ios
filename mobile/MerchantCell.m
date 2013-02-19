//
//  MerchantCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantCell.h"

@implementation MerchantCell

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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


- (void)setMerchant:(Merchant *)newMerchant {
    if (newMerchant != merchant) {
        merchant = newMerchant;
        
        //imageView.image = merchant.thumbnailImage;
        //nameLabel.text = merchant.name;
        //descriptionLabel.text = merchant.description;
        //prepTimeLabel.text = merchant.prepTime;
    }
}

/*
 Set the recipe object onto the table view cell.
 */
- (Merchant *)merchant {
    return merchant;
}


@end
