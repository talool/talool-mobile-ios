//
//  FriendCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerCell.h"

@interface FriendCell : CustomerCell {
    
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *pointsLabel;
    
}

@end
