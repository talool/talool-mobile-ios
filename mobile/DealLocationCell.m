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
#import "FontAwesomeKit.h"

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
    
    
    if ([merchant.locations count]>1)
    {
        [merchantAddress setText:[merchant getLocationLabel]];
        // add prompt to view the map
        NSString *message = @"check the map";
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@", message, FAKIconAngleRight]];
        UIFont *fa = [UIFont fontWithName:@"FontAwesome" size:10.0];
        UIFont *verdana = [UIFont fontWithName:@"Verdana" size:10.0];
        [text addAttribute:NSFontAttributeName value:verdana range:NSMakeRange(0, [message length])];
        [text addAttribute:NSFontAttributeName value:fa range:NSMakeRange([text length] - 1, 1)];
        [merchantCityState setAttributedText:text];
    }
    else
    {
        [merchantAddress setText:merchantLocation.address.address1];
        [merchantCityState setText:[NSString stringWithFormat:@"%@, %@ %@",
                                    merchantLocation.address.city,
                                    merchantLocation.address.stateProvidenceCounty,
                                    merchantLocation.address.zip]];
    }
    
}

@end
