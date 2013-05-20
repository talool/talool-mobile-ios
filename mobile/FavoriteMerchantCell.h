//
//  MerchantCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MerchantCell.h"
//#import "RatingView.h"

@interface FavoriteMerchantCell : MerchantCell
{
    
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addressLabel;

}

@end
