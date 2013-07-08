//
//  OfferActionView.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferActionView.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import <StoreKit/StoreKit.h>

@implementation OfferActionView
{
    NSNumberFormatter * _priceFormatter;
}

@synthesize delegate, product;

- (id)initWithFrame:(CGRect)frame product:(SKProduct *)skproduct
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferActionView" owner:self options:nil];
        
        product = skproduct;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *label = [NSString stringWithFormat:@"Buy Now For %@",[_priceFormatter stringFromNumber:product.price]];
        
        [self.buyButton useTaloolStyle];
        [self.buyButton setBaseColor:[TaloolColor orange]];
        [self.buyButton setTitle:label forState:UIControlStateNormal];
        
        [self addSubview:view];
    }
    return self;
}

- (IBAction)buyAction:(id)sender {
    [delegate buyNow:product sender:self];
}

@end
