//
//  DealCell.h
//  Talool
//
//  Created by Douglas McCuen on 6/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDeal;

@interface DealCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *summaryLabel;
    IBOutlet UILabel *merchantLabel;
    
    ttDeal *deal;
    
}


@property (nonatomic, retain) ttDeal *deal;
@property (retain, nonatomic) UILabel *summaryLabel;
@property (retain, nonatomic) UIImageView *iconView;
@property (retain, nonatomic) UILabel *merchantLabel;

@end
