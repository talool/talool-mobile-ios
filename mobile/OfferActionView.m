//
//  OfferActionView.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferActionView.h"
#import "TaloolColor.h"

@implementation OfferActionView
{
    NSNumberFormatter * _priceFormatter;
}

@synthesize product, spinner;

- (id)initWithFrame:(CGRect)frame productId:(NSString *)productId
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferActionView" owner:self options:nil];
        
        product = nil;
        _productId = productId;
        
        // NOTE: harding the default price of the books
        NSNumber *defaultPrice = [NSNumber numberWithFloat:9.99];
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *label = [NSString stringWithFormat:@"Buy Now For %@",[_priceFormatter stringFromNumber:defaultPrice]];
        [self.buyButton setTitle:label forState:UIControlStateNormal];
        
        self.spinner.hidesWhenStopped = YES;
        
        [self addSubview:view];
    }
    return self;
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

- (IBAction)buyAction:(id)sender {

    
}

- (void) stopSpinner
{
    [spinner stopAnimating];
}


@end
