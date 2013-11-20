//
//  DealOfferCell.h
//  Talool
//
//  Created by Douglas McCuen on 11/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealOfferCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *brandingView;
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *statsLabel;
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;

@end
