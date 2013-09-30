//
//  DefaultGiftLayoutState.h
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealLayoutState.h"

#define ROW_GIFT_DETAIL    100.0f

@class ttGift;

@interface DefaultGiftLayoutState : DealLayoutState

- (id) initWithGift:(ttGift *)gift offer:(ttDealOffer *)dealOffer actionDelegate:(id<TaloolGiftActionDelegate>)actionDelegate;

@property (nonatomic, strong) ttGift *gift;

@end
