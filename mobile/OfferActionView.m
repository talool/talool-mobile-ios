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
#import "talool-api-ios/ttDealOffer.h"

@implementation OfferActionView

@synthesize delegate, offer;

- (id)initWithFrame:(CGRect)frame offer:(ttDealOffer *)dealOffer
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferActionView" owner:self options:nil];
        
        offer = dealOffer;
        
        [self.buyButton useTaloolStyle];
        [self.buyButton setBaseColor:[TaloolColor teal]];
        NSString *label = [NSString stringWithFormat:@"Buy for $%@",offer.price];
        [self.buyButton setTitle:label forState:UIControlStateNormal];
        
        [self addSubview:view];
    }
    return self;
}

- (IBAction)buyAction:(id)sender {
    [delegate buyNow:offer sender:self];
}

@end
