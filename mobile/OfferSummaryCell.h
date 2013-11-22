//
//  OfferSummaryCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealOffer;

@interface OfferSummaryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *summary;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

- (void) setOffer:(ttDealOffer *)offer;

@end
