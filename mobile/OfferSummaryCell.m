//
//  OfferSummaryCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferSummaryCell.h"
#import "Talool-API/ttDealOffer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OfferSummaryCell

- (void) setOffer:(ttDealOffer *)offer
{
    self.summary.text = offer.summary;
    
    [self.logo sd_setImageWithURL:[NSURL URLWithString:offer.imageUrl]
                      placeholderImage:[UIImage imageNamed:@"000.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (error !=  nil) {
                                     // TODO track these errors
                                     NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                 }
                             }];
}

@end
