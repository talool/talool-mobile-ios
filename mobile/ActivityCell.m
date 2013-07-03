//
//  ActivityCell.m
//  Talool
//
//  Created by Douglas McCuen on 6/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityCell.h"
#import "talool-api-ios/ttActivity.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"

@implementation ActivityCell

@synthesize titleLabel, iconView, dateLabel, subtitleLabel, activity;

- (void)setActivity:(ttActivity *)newActivity
{
    activity = newActivity;
    titleLabel.text = activity.title;
    subtitleLabel.text = activity.subtitle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    dateLabel.text = [dateFormatter stringFromDate:activity.activityDate];

    if ([activity isFacebookReceiveGiftEvent] ||
        [activity isEmailReceiveGiftEvent])
    {
        if ([activity isClosed])
        {
            iconView.image = [IconHelper getImageForIcon:FAKIconGift color:[TaloolColor gray_3]];
        }
        else
        {
            iconView.image = [IconHelper getImageForIcon:FAKIconGift color:[TaloolColor teal]];
        }
    }
    else if ([activity isRejectGiftEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconGift color:[TaloolColor gray_2]];
    }
    else if ([activity isEmailSendGiftEvent] ||
             [activity isFacebookSendGiftEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconGift color:[TaloolColor gray_3]];
    }
    else if ([activity isPurchaseEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconMoney color:[TaloolColor green]];
    }
    else if ([activity isWelcomeEvent] ||
             [activity isMerchantReachEvent] ||
             [activity isTaloolReachEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconEnvelopeAlt color:[TaloolColor teal]];
    }
    else if ([activity isRedeemEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconMoney color:[TaloolColor gray_3]];
    }
    else if ([activity isFriendGiftAcceptEvent] ||
             [activity isFriendGiftRedeemEvent] ||
             [activity isFriendGiftRejectEvent] ||
             [activity isFriendPurchaseEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconGroup color:[TaloolColor gray_3]];
    }
    else
    { 
        iconView.image = [IconHelper getImageForIcon:FAKIconQuestion color:[TaloolColor gray_1]];
    }
}

@end
