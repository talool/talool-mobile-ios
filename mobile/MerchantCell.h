//
//  ApplicationCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Talool-API/ttMerchant.h"


@interface MerchantCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addressLabel;
}

- (void)setMerchant:(ttMerchant *)merchant;

@end
