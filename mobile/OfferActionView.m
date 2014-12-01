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

@implementation OfferActionView
{
    NSNumberFormatter * _priceFormatter;
    NSArray * _originalToolbarItems;
    NSArray * _limitedToolbarItems;
    NSArray * _freeToolbarItems;
    id<TaloolDealOfferActionDelegate> _delegate;
}

@synthesize offer;

- (id)initWithFrame:(CGRect)frame delegate:(id<TaloolDealOfferActionDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OfferActionView" owner:self options:nil];
        
        _delegate = delegate;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        FAKFontAwesome *buyIcon = [FAKFontAwesome moneyIconWithSize:16];
        FAKFontAwesome *codeIcon = [FAKFontAwesome bookIconWithSize:16];
        
        NSDictionary *attr =@{NSForegroundColorAttributeName:[TaloolColor dark_teal],
                              NSFontAttributeName:[codeIcon iconFont]
                              };
        NSDictionary *attr2 =@{NSForegroundColorAttributeName:[TaloolColor orange],
                               NSFontAttributeName:[buyIcon iconFont]
                               };
        
        [buyButton setTitle:[NSString stringWithFormat:@"%@  %@", buyIcon.characterCode, @"Buy Now"]];
        [buyButton setTitleTextAttributes:attr2 forState:UIControlStateNormal];
        [activateButton setTitle:[NSString stringWithFormat:@"%@  %@", codeIcon.characterCode, @"Enter Code"]];
        [activateButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        
        _originalToolbarItems = toolbar.items;
        NSMutableArray *newToolBarArray = [NSMutableArray arrayWithArray:toolbar.items];
        [newToolBarArray removeObjectAtIndex:1];
        [newToolBarArray removeObjectAtIndex:3];
        _limitedToolbarItems = newToolBarArray;
        
        NSMutableArray *freeToolBarArray = [NSMutableArray arrayWithArray:_originalToolbarItems];
        [freeToolBarArray removeObjectAtIndex:3];
        _freeToolbarItems = freeToolBarArray;
        
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
    
    // Hide the buy button if the deal offer is expired
    NSDate *today = [NSDate date];
    if ([offer isFree]==YES)
    {
        [toolbar setItems:_freeToolbarItems animated:NO];
        FAKFontAwesome *bookIcon = [FAKFontAwesome bookIconWithSize:16];
        [buyButton setTitle:[NSString stringWithFormat:@"%@  %@", bookIcon.characterCode, @"Download"]];
        
    }
    else if ([today compare:offer.expires] == NSOrderedDescending) {
        [toolbar setItems:_limitedToolbarItems animated:NO];
    }
    else
    {
        [toolbar setItems:_originalToolbarItems animated:NO];
        FAKFontAwesome *buyIcon = [FAKFontAwesome moneyIconWithSize:16];
        [buyButton setTitle:[NSString stringWithFormat:@"%@  %@", buyIcon.characterCode, @"Buy Now"]];
    }
    
}


@end
