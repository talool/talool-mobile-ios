//
//  RewardCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttDeal.h"

@interface RewardCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UIView *redeemedView;
    
    ttDeal *deal;
    
}

@property (nonatomic, retain) ttDeal *deal;

@end
