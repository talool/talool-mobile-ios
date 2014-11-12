//
//  OfferSummaryView.m
//  Talool
//
//  Created by Douglas McCuen on 11/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferSummaryView.h"
#import "Talool-API/ttDealOffer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OfferSummaryView
{
    NSNumberFormatter * _priceFormatter;
}

@synthesize offer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferSummaryView" owner:self options:nil];
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        [self addSubview:view];
    }
    return self;
}

-(void) updateOffer:(ttDealOffer *)newOffer
{
    offer = newOffer;
    
    if (offer.backgroundUrl)
    {

        [dealOfferImage sd_setImageWithURL:[NSURL URLWithString:offer.backgroundUrl]
                          placeholderImage:[UIImage imageNamed:@"000.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    
    priceLabel.text = [NSString stringWithFormat:@"Price: %@",[_priceFormatter stringFromNumber:[offer price]]];
    summaryLabel.text = offer.summary;
    
}

@end
