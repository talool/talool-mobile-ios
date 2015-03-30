//
//  GiftDetailCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "GiftDetailCell.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttFriend.h"

@implementation GiftDetailCell

- (void)setGift:(ttGift *)gift
{
    details.text = (gift.fromCustomer.firstName)?gift.fromCustomer.firstName:@"Someone";
}

@end
