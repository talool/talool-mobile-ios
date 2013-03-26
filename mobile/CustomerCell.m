//
//  CustomerCell.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerCell.h"

@implementation CustomerCell

@synthesize useDarkBackground, socialFriend, icon, name, points, talools;

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

- (void)setUseDarkBackground:(BOOL)flag
{
    if (flag != useDarkBackground || !self.backgroundView)
    {
        useDarkBackground = flag;
    }
}

- (void)setSocialFriend:(Friend *)friend {
    if (friend != socialFriend) {
        socialFriend = friend;
        
        //self.icon = customer.thumbnailImage;
        self.name = [NSString stringWithFormat:@"%@ %@", socialFriend.firstName, socialFriend.lastName];
        //self.points = customer.points;
        //self.talools = customer.talools;
    }
}

- (Friend *)friend {
    return socialFriend;
}


@end
