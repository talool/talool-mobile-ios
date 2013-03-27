//
//  RewardCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttCoupon.h"

@interface RewardCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *pointsLabel;
    
    ttCoupon *deal;
    
}

@property (nonatomic, retain) ttCoupon *deal;

@end
