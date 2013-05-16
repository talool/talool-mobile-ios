//
//  LocationCell.h
//  Talool
//
//  Created by Douglas McCuen on 5/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttMerchantLocation;

@interface LocationCell : UITableViewCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addressLabel;
    
    ttMerchantLocation *location;
    
}

@property (nonatomic, retain) ttMerchantLocation *location;

@end
