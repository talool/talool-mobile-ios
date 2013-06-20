//
//  ActivityCell.m
//  Talool
//
//  Created by Douglas McCuen on 6/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityCell.h"

@implementation ActivityCell

@synthesize titleLabel, iconView, dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
