//
//  OfferMerchantView.m
//  Talool
//
//  Created by Douglas McCuen on 11/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferMerchantView.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OfferMerchantView

@synthesize offer, merchant;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferMerchantView" owner:self options:nil];
        
        [self addSubview:view];
    }
    return self;
}

-(void) updateView:(ttDealOffer *)newOffer merchant:(ttMerchant *)merch
{
    offer = newOffer;
    merchant = merch;
    
    if (offer.backgroundUrl)
    {
        [dealOfferImage setImageWithURL:[NSURL URLWithString:offer.backgroundUrl]
                       placeholderImage:[UIImage imageNamed:@"000.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                  }
                                  
                              }];
    }
    else
    {
        dealOfferImage.image = [UIImage imageNamed:@"DealOfferBG"];
    }
    
    [merchantLogo setImageWithURL:[NSURL URLWithString:merchant.closestLocation.logoUrl]
                   placeholderImage:[UIImage imageNamed:@"000.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                              }
                              
                          }];
    
    NSString *summary = [NSString stringWithFormat:@"%@ has partnered with %@ to make the following deal(s) available in the %@.", offer.merchant.name, merchant.name, offer.title];
    summaryLabel.text = summary;
}

@end
