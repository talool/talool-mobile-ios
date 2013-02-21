//
//  MerchantCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationCell.h"
//#import "RatingView.h"

@interface FavoriteMerchantCell : ApplicationCell
{
    
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *publisherLabel;
    IBOutlet UILabel *nameLabel;
    //IBOutlet RatingView *ratingView;
    //IBOutlet UILabel *numRatingsLabel;
    IBOutlet UILabel *priceLabel;
}

@end
