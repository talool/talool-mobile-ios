//
//  OfferActionView.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferActionView.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import "Talool-API/ttDealOffer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OfferActionView
{
    NSNumberFormatter * _priceFormatter;
    id<TaloolDealOfferActionDelegate> _delegate;
}

@synthesize offer;

- (id)initWithFrame:(CGRect)frame offer:(ttDealOffer *)dealOffer delegate:(id<TaloolDealOfferActionDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferActionView" owner:self options:nil];
        
        offer = dealOffer;
        _delegate = delegate;
        
        [dealOfferImage setImageWithURL:[NSURL URLWithString:offer.imageUrl]
                       placeholderImage:[UIImage imageNamed:@"000.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                  }
                             
                              }];
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        priceLabel.text = [NSString stringWithFormat:@"Price: %@",[_priceFormatter stringFromNumber:[offer price]]];
        
        
        NSDictionary *attr =@{NSForegroundColorAttributeName:[TaloolColor dark_teal],
                              NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                              };
        NSDictionary *attr2 =@{NSForegroundColorAttributeName:[TaloolColor orange],
                               NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                               };
        [buyButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconMoney, @"Buy Now"]];
        [buyButton setTitleTextAttributes:attr2 forState:UIControlStateNormal];
        [activateButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconBook, @"Enter Code"]];
        [activateButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        
        [self addSubview:view];
    }
    return self;
}

- (IBAction)buyAction:(id)sender {
    [_delegate buyNow:self];
}

- (IBAction)activateAction:(id)sender {
    [_delegate activateCode:self];
}


@end
