//
//  DealOfferLogoCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferLogoCell.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealOffer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DealOfferLogoCell


- (void) setDealOffer:(ttDealOffer *)offer deal:(ttDeal *)deal
{
    
    [logo setImageWithURL:[NSURL URLWithString:offer.imageUrl]
         placeholderImage:[UIImage imageNamed:@"000.png"]
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (error !=  nil) {
                        // TODO track these errors
                        NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                    }
                                   
                }];
    
    NSString *exp;
    if (deal.expires == nil)
    {
        exp = @"Never Expires";
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        exp = [NSString stringWithFormat:@"Expires %@", [dateFormatter stringFromDate:deal.expires]];
    }
    
    [expires setText:exp];
}


@end
