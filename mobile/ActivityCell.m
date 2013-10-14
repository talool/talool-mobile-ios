//
//  ActivityCell.m
//  Talool
//
//  Created by Douglas McCuen on 6/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityCell.h"
#import "Talool-API/ttActivity.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@implementation ActivityCell

@synthesize titleLabel, iconView, dateLabel, subtitleLabel, activity, cellBackground, disclosureIndicator;

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
        iconView.image = [IconHelper getImageForIcon:FAKIconGift color:[TaloolColor gray_3]];
    }
    else if ([activity isEmailSendGiftEvent] ||
             [activity isFacebookSendGiftEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconGift color:[TaloolColor gray_3]];
    }
    else if ([activity isPurchaseEvent])
    {
        iconView.image = [IconHelper getImageForIcon:FAKIconMoney color:[TaloolColor gray_3]];
    }
    else if ([activity isWelcomeEvent] ||
             [activity isMerchantReachEvent] ||
             [activity isTaloolReachEvent])
    {
        if ([activity isClosed])
        {
            iconView.image = [IconHelper getImageForIcon:FAKIconEnvelopeAlt color:[TaloolColor gray_3]];
        }
        else
        {
            iconView.image = [IconHelper getImageForIcon:FAKIconEnvelopeAlt color:[TaloolColor teal]];
        }
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
    
    disclosureIndicator.image = [FontAwesomeKit imageForIcon:FAKIconChevronRight
                                                        imageSize:CGSizeMake(30, 30)
                                                         fontSize:14
                                                       attributes:@{ FAKImageAttributeForegroundColor:[TaloolColor gray_2] }];
}

@end
