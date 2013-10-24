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
    NSArray * _originalToolbarItems;
    NSArray * _limitedToolbarItems;
    id<TaloolDealOfferActionDelegate> _delegate;
}

@synthesize offer;

- (id)initWithFrame:(CGRect)frame offer:(ttDealOffer *)dealOffer delegate:(id<TaloolDealOfferActionDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferActionView" owner:self options:nil];
        
        _delegate = delegate;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
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
        
        _originalToolbarItems = toolbar.items;
        NSMutableArray *newToolBarArray = [NSMutableArray arrayWithArray:toolbar.items];
        [newToolBarArray removeObjectAtIndex:1];
        _limitedToolbarItems = newToolBarArray;
        
        [self updateOffer:dealOffer];
        
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

-(void) updateOffer:(ttDealOffer *)newOffer
{
    offer = newOffer;
    
    [dealOfferImage setImageWithURL:[NSURL URLWithString:offer.imageUrl]
                   placeholderImage:[UIImage imageNamed:@"000.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                              }
                              
                          }];
    
    priceLabel.text = [NSString stringWithFormat:@"Price: %@",[_priceFormatter stringFromNumber:[offer price]]];
    
    // Hide the buy button if the deal offer is expired
    NSDate *today = [NSDate date];
    if ([today compare:offer.expires] == NSOrderedDescending) {
        [toolbar setItems:_limitedToolbarItems animated:NO];
    }
    else
    {
        [toolbar setItems:_originalToolbarItems animated:NO];
    }
    
#warning "TODO we should hide the buy button is the offer is inactive."
    
}


@end
