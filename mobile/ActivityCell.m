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

@synthesize titleLabel, iconView, dateLabel, subtitleLabel, activity;

- (void)setActivity:(ttActivity *)newActivity
{
    activity = newActivity;
    titleLabel.text = activity.title;
    subtitleLabel.text = activity.subtitle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy' at 'h:mm a"];
    dateLabel.text = [dateFormatter stringFromDate:activity.activityDate];
    
    UIColor *iconColor;
    if ([activity isClosed])
    {
        iconColor = [TaloolColor gray_3];
    }
    else
    {
        iconColor = [TaloolColor teal];
    }

    if ([activity isFacebookReceiveGiftEvent] ||
        [activity isRejectGiftEvent] ||
        [activity isEmailReceiveGiftEvent] ||
        [activity isEmailSendGiftEvent] ||
        [activity isFacebookSendGiftEvent])
    {
        iconView.image = [IconHelper getImageForIcon:[FAKFontAwesome giftIconWithSize:24] color:iconColor];
    }
    else if ([activity isPurchaseEvent] ||
             [activity isRedeemEvent])
    {
        iconView.image = [IconHelper getImageForIcon:[FAKFontAwesome moneyIconWithSize:24] color:iconColor];
    }
    else if ([activity isFriendGiftAcceptEvent] ||
             [activity isFriendGiftRedeemEvent] ||
             [activity isFriendGiftRejectEvent] ||
             [activity isFriendPurchaseEvent])
    {
        iconView.image = [IconHelper getImageForIcon:[FAKFontAwesome groupIconWithSize:24] color:iconColor];
    }
    else
    {
        iconView.image = [IconHelper getImageForIcon:[FAKFontAwesome envelopeOIconWithSize:24] color:iconColor];
    }
    
}

@end
