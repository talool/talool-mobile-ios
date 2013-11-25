//
//  DealOfferDealCell.h
//  Talool
//
//  Created by Douglas McCuen on 11/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDeal;

@interface DealOfferDealCell : UITableViewCell
{
    IBOutlet UIImageView *bgImageView;
    IBOutlet UILabel *summaryLabel;
}

- (void)setDeal:(ttDeal *)deal;

@end
