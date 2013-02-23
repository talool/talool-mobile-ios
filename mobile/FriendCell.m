//
//  FriendCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    pointsLabel.backgroundColor = backgroundColor;
}

- (void)setIcon:(UIImage *)newIcon
{
    [super setIcon:newIcon];
    iconView.image = newIcon;
}

- (void)setName:(NSString *)newName
{
    [super setName:newName];
    nameLabel.text = newName;
}

- (void)setPoints:(NSString *)newPoints
{
    [super setPoints:newPoints];
    pointsLabel.text = newPoints;
}


@end
