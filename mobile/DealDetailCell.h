//
//  DealDetailCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDeal;

@interface DealDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *summary;
@property (strong, nonatomic) IBOutlet UILabel *details;

- (void) setDeal:(ttDeal *)deal;

@end
