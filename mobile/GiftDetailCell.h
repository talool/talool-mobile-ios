//
//  GiftDetailCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttGift;

@interface GiftDetailCell : UITableViewCell
{
    IBOutlet UILabel *details;
    
}

- (void)setGift:(ttGift *)gift;

@end
