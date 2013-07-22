//
//  OfferActionView.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OfferActionView.h"
#import "TaloolColor.h"
#import "TaloolIAPHelper.h"
#import <StoreKit/StoreKit.h>

@implementation OfferActionView
{
    NSNumberFormatter * _priceFormatter;
}

@synthesize product, spinner;

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
        [self.buyButton setTitle:label forState:UIControlStateNormal];
        
        self.spinner.hidesWhenStopped = YES;
        
        [self addSubview:view];
    }
    return self;
}

// It can take a long time to get the list of products back from iTunes,
// so this init methods allows us show a buy button without a price (or a default price)
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

    if (product == nil)
    {
        product = [[TaloolIAPHelper sharedInstance] getProductForIdentifier:_productId];
        if (product ==  nil)
        {
            NSLog(@"Purchased failed.  Couldn't load products from itunes");
            UIAlertView *itunesError = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
                                                             message:@"We're not able to connect to iTunes in order to complete your purchase.  Please try again later."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [itunesError show];
            return;
        }
    }
    
    [[TaloolIAPHelper sharedInstance] buyProduct:product];
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
}

- (void) stopSpinner
{
    [spinner stopAnimating];
}


@end
