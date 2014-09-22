//
//  DealActionBar3View.m
//  Talool
//
//  Created by Douglas McCuen on 7/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealActionBar3View.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttGiftDetail.h"
#import "FacebookHelper.h"
#import "CustomerHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@implementation DealActionBar3View

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcq delegate:(id<TaloolDealActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"DealActionBar3View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        FAKFontAwesome *moneyIcon = [FAKFontAwesome moneyIconWithSize:16];
        FAKFontAwesome *giftIcon = [FAKFontAwesome giftIconWithSize:16];
        
        NSDictionary *attr =@{NSForegroundColorAttributeName:[TaloolColor dark_teal],
                              NSFontAttributeName:[giftIcon iconFont]
                              };
        NSDictionary *attr2 =@{NSForegroundColorAttributeName:[TaloolColor orange],
                              NSFontAttributeName:[moneyIcon iconFont]
                              };
        [redeemButton setTitle:[NSString stringWithFormat:@"%@  %@", moneyIcon.characterCode, @"Redeem Now"]];
        [redeemButton setTitleTextAttributes:attr2 forState:UIControlStateNormal];
        [emailButton setTitle:[NSString stringWithFormat:@"%@  %@", giftIcon.characterCode, @"Give As Gift"]];
        [emailButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        
        [self updateView:dealAcq];
        
        [inactiveView setBackgroundColor:[TaloolColor orange]];
        
        [self addSubview:view];
    }
    return self;
}

- (void) updateView:(ttDealAcquire *)dealAcquire
{
    
    [[CustomerHelper getContext] refreshObject:dealAcquire.deal mergeChanges:YES];
    
    [dealImage setImageWithURL:[NSURL URLWithString:dealAcquire.deal.imageUrl] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // manage the state of the view
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy' at 'h:mm:ss a"];
    
    if ([dealAcquire hasBeenRedeemed])
    {
        if (dealAcquire.redemptionCode && dealAcquire.redeemed)
        {
            message.text = [NSString stringWithFormat:@"Redemption Code %@ issued on %@", dealAcquire.redemptionCode, [dateFormatter stringFromDate:dealAcquire.redeemed]];
        }
        else if (dealAcquire.redemptionCode)
        {
            message.text = [NSString stringWithFormat:@"Redemption Code: %@", dealAcquire.redemptionCode];
        }
        else if (dealAcquire.redeemed)
        {
            message.text = [NSString stringWithFormat:@"Redeemed on %@",
                            [dateFormatter stringFromDate:dealAcquire.redeemed]];
        }
        else
        {
            message.text = @"Redeemed";
        }
        
        [twoButtonView setHidden:YES];
        [inactiveView setHidden:NO];
    }
    else if ([dealAcquire hasBeenShared])
    {
        if ((dealAcquire.giftDetail))
        {
            if (dealAcquire.giftDetail.toName)
            {
                message.text = [NSString stringWithFormat:@"Gifted to %@", dealAcquire.giftDetail.toName];
            }
            else
            {
                message.text = [NSString stringWithFormat:@"Gifted to %@", dealAcquire.giftDetail.toEmail];
            }
        }
        else if (dealAcquire.sharedTo)
        {
            NSString *friendLabel;
            ttFriend *friend = dealAcquire.sharedTo;
            if (friend.email)
            {
                friendLabel = [NSString stringWithFormat:@"Gifted to %@", friend.email];
            }
            else
            {
                friendLabel = [NSString stringWithFormat:@"Gifted to %@", friend.firstName];
            }
            message.text = friendLabel;
        }
        else if (dealAcquire.shared)
        {
            message.text = [NSString stringWithFormat:@"Gifted on %@",
                            [dateFormatter stringFromDate:dealAcquire.shared]];
        }
        else
        {
            message.text = @"Gifted to a friend %@";
        }
        
        [twoButtonView setHidden:YES];
        [inactiveView setHidden:NO];
    }
    else if ([dealAcquire hasExpired])
    {
        message.text = [NSString stringWithFormat:@"Expired on %@",
                        [dateFormatter stringFromDate:dealAcquire.deal.expires]];
        [inactiveView setHidden:NO];
        [twoButtonView setHidden:YES];
    }
    else
    {
        [inactiveView setHidden:YES];
        [twoButtonView setHidden:NO];
    }
    
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (IBAction)redeemAction:(id)sender {
    [self.delegate dealRedeemed:self];
}

- (IBAction)giftAction:(id)sender {
    [self.delegate sendGift:self];
}

@end
