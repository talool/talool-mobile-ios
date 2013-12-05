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

@implementation DealActionBar3View

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcq delegate:(id<TaloolDealActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"DealActionBar3View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        NSDictionary *attr =@{NSForegroundColorAttributeName:[TaloolColor dark_teal],
                              NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                              };
        NSDictionary *attr2 =@{NSForegroundColorAttributeName:[TaloolColor orange],
                              NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                              };
        [redeemButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconMoney, @"Redeem Now"]];
        [redeemButton setTitleTextAttributes:attr2 forState:UIControlStateNormal];
        [emailButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconGift, @"Give As Gift"]];
        [emailButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        
        [self updateView:dealAcq];
        
        [self addSubview:view];
    }
    return self;
}

- (void) updateView:(ttDealAcquire *)dealAcquire
{
    
    [dealImage setImageWithURL:[NSURL URLWithString:dealAcquire.deal.imageUrl]
          placeholderImage:[UIImage imageNamed:@"000.png"]
                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                     if (error !=  nil) {
                         // TODO track these errors
                         NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                     }
                     
                 }];
    
    // manage the state of the view
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy 'at' HH:mm:ss"];
    
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
            message.text = [NSString stringWithFormat:@"Gifted to %@", dealAcquire.giftDetail.toEmail];
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

- (void) startSpinner
{
    [spinner startAnimating];
}

- (void) stopSpinner
{
    [spinner stopAnimating];
}

@end
