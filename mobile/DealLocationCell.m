//
//  DealLocationCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealLocationCell.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttAddress.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DealLocationCell

-(void) setMerchant:(ttMerchant *)merchant;
{
    
    ttMerchantLocation *merchantLocation = [merchant getClosestLocation];
    
    [merchantLogo setImageWithURL:[NSURL URLWithString: merchantLocation.logoUrl]
         placeholderImage:[UIImage imageNamed:@"000.png"]
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (error !=  nil) {
                        // TODO track these errors
                        NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                    }
                    
                }];
    
    
    // TODO handle multiple locations
    [merchantAddress setText:merchantLocation.address.address1];
    [merchantCityState setText:[NSString stringWithFormat:@"%@, %@ %@",
                                merchantLocation.address.city,
                                merchantLocation.address.stateProvidenceCounty,
                                merchantLocation.address.zip]];
}

@end
