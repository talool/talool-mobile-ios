//
//  DealActionBar3View.m
//  Talool
//
//  Created by Douglas McCuen on 7/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealActionBar3View.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttCustomer.h"
#import "FacebookHelper.h"
#import "CustomerHelper.h"

@implementation DealActionBar3View

- (id)initWithFrame:(CGRect)frame deal:(ttDealAcquire *)dealAcq delegate:(id<TaloolDealActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"DealActionBar3View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        int iconFontSize = 32;
        int iconSize = 35;
        NSDictionary *attr =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
        
        UIImage *icon = [FontAwesomeKit imageForIcon:FAKIconMoney
                                           imageSize:CGSizeMake(iconSize, iconSize)
                                            fontSize:iconFontSize
                                          attributes:attr];
        redeemIcon.image = icon;
        redeemLabel.text = @"Use Deal Now";
        redeemIcon2.image = icon;
        redeemLabel2.text = @"Use Deal Now";
        
        
        icon = [FontAwesomeKit imageForIcon:FAKIconFacebook
                                  imageSize:CGSizeMake(iconSize, iconSize)
                                   fontSize:iconFontSize
                                 attributes:attr];
        facebookIcon.image = icon;
        facebookLabel.text = @"Gift via Facebook";
        
        icon = [FontAwesomeKit imageForIcon:FAKIconEnvelopeAlt
                                  imageSize:CGSizeMake(iconSize, iconSize)
                                   fontSize:iconFontSize
                                 attributes:attr];
        emailIcon.image = icon;
        emailLabel.text = @"Gift via Email";
        emailIcon2.image = icon;
        emailLabel2.text = @"Gift via Email";
        
        [self updateView:dealAcq];
        
        [self addSubview:view];
    }
    return self;
}

- (void) updateView:(ttDealAcquire *)dealAcquire
{
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
        [threeButtonView setHidden:YES];
        [inactiveView setHidden:NO];
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
        else if (dealAcquire.shared)
        {
            message.text = [NSString stringWithFormat:@"Gifted on %@",
                            [dateFormatter stringFromDate:dealAcquire.shared]];
        }
        else
        {
            message.text = @"Gifted to a friend";
        }
        
        [twoButtonView setHidden:YES];
         [threeButtonView setHidden:YES];
         [inactiveView setHidden:NO];
    }
    else if ([dealAcquire hasExpired])
    {
        message.text = [NSString stringWithFormat:@"Expired on %@",
                        [dateFormatter stringFromDate:dealAcquire.deal.expires]];
        [twoButtonView setHidden:YES];
        [threeButtonView setHidden:YES];
        [inactiveView setHidden:NO];
    }
    else
    {
        if ([FBSession activeSession].isOpen || [[CustomerHelper getLoggedInUser] isFacebookUser])
        {
            [threeButtonView setHidden:NO];
            [twoButtonView setHidden:YES];
        }
        else
        {
            [threeButtonView setHidden:YES];
            [twoButtonView setHidden:NO];
        }
        
        [inactiveView setHidden:YES];
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

- (IBAction)facebookAction:(id)sender {
    [self.delegate sendGiftViaFacebook:self];
}

- (IBAction)emailAction:(id)sender {
    [self.delegate sendGiftViaEmail:self];
}
@end
