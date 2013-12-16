//
//  ActivityCell.h
//  Talool
//
//  Created by Douglas McCuen on 6/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttActivity;

@interface ActivityCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *subtitleLabel;
    IBOutlet UILabel *dateLabel;
    
    ttActivity *activity;
}

@property (nonatomic, retain) ttActivity *activity;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *subtitleLabel;
@property (retain, nonatomic) UIImageView *iconView;
@property (retain, nonatomic) UILabel *dateLabel;
@end
