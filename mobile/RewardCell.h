//
//  RewardCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealAcquire;

@interface RewardCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UIView *redeemedView;
    
    ttDealAcquire *deal;
    
}

@property (nonatomic, retain) ttDealAcquire *deal;

@end
