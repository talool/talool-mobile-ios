//
//  DealOfferDealCell.m
//  Talool
//
//  Created by Douglas McCuen on 11/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferDealCell.h"
#import "Talool-API/ttDeal.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TaloolColor.h"

@implementation DealOfferDealCell

- (void)setDeal:(ttDeal *)deal
{
    summaryLabel.text = deal.summary;
    [sampleLabel setTextColor:[TaloolColor orange]];
    
    /*
    [bgImageView setImageWithURL:[NSURL URLWithString:deal.imageUrl]
                placeholderImage:[UIImage imageNamed:@"000.png"]
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                              }
                              
                       }];
     */
}

@end
