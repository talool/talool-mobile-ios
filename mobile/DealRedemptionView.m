//
//  DealRedemptionView.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealRedemptionView.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttFriend.h"

@implementation DealRedemptionView

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcquire delegate:(id<TaloolDealActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = actionDelegate;
        
        [[NSBundle mainBundle] loadNibNamed:@"DealRedemptionView" owner:self options:nil];
        
        [redeemButton useTaloolStyle];
        [redeemButton setBaseColor:[TaloolColor orange]];
        [redeemButton setTitle:@"Use This Deal" forState:UIControlStateNormal];
        [redeemButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-BoldItalic" size:24.0]];
        
        [self updateView:dealAcquire];
        
        [self addSubview:view];
    }
    return self;
}

- (IBAction)redeemAction:(id)sender {
    [self.delegate dealRedeemed:self];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) updateView:(ttDealAcquire *)dealAcquire
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    if ([dealAcquire hasBeenRedeemed])
    {
        if (dealAcquire.redemptionCode)
        {
            message.text = [NSString stringWithFormat:@"Redemption Code: %@", dealAcquire.redemptionCode];
        }
        else
        {
            message.text = [NSString stringWithFormat:@"Redeemed on %@",
                            [dateFormatter stringFromDate:dealAcquire.redeemed]];
        }
        
        [redeemButton setHidden:YES];
        [message setHidden:NO];
    }
    else if ([dealAcquire hasBeenShared])
    {
        if (dealAcquire.sharedTo)
        {
            NSString *friendLabel;
            if (dealAcquire.sharedTo.email == nil)
            {
                friendLabel = [NSString stringWithFormat:@"Gifted to %@", dealAcquire.sharedTo.fullName];
            }
            else
            {
                friendLabel = [NSString stringWithFormat:@"Gifted to %@", dealAcquire.sharedTo.email];
            }
            message.text = friendLabel;
        }
        else
        {
            message.text = [NSString stringWithFormat:@"Shared on %@",
                            [dateFormatter stringFromDate:dealAcquire.shared]];
        }
        
        [redeemButton setHidden:YES];
        [message setHidden:NO];
    }
    else if ([dealAcquire hasExpired])
    {
        message.text = [NSString stringWithFormat:@"Expired on %@",
                        [dateFormatter stringFromDate:dealAcquire.deal.expires]];
        [redeemButton setHidden:YES];
        [message setHidden:NO];
    }
    else
    {
        [message setHidden:YES];
    }
    
}

@end
