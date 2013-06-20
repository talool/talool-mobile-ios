//
//  ActivityCell.h
//  Talool
//
//  Created by Douglas McCuen on 6/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *dateLabel;
}

@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIImageView *iconView;
@property (retain, nonatomic) UILabel *dateLabel;

@end
