//
//  DealOfferCell.h
//  Talool
//
//  Created by Douglas McCuen on 11/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealOfferCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *brandingView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statsLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end
