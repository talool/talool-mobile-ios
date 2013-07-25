//
//  GiftDetailCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "GiftDetailCell.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttFriend.h"

@implementation GiftDetailCell

- (void)setGift:(ttGift *)gift
{
    details.text = gift.fromCustomer.firstName;
}

@end
