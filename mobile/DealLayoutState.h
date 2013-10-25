//
//  DealLayoutState.h
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaloolProtocols.h"
#import "DealLocationCell.h"
#import "DealDetailCell.h"
#import "DealOfferLogoCell.h"

#define ROW_HEIGHT_LOCATION    60.0f
#define ROW_HEIGHT_HERO    100.0f
#define ROW_HEIGHT_OFFER    50.0f

@class ttDealAcquire;

@interface DealLayoutState : NSObject<TaloolDealLayoutDelegate>

- (id) initWithDeal:(ttDealAcquire *)dealAcquire offer:(ttDealOffer *)dealOffer actionDelegate:(id<TaloolDealActionDelegate>)actionDelegate;
- (void) calcDetailSize:(ttDeal *)deal;

@property (nonatomic, strong) ttDealAcquire *deal;
@property (nonatomic, strong) ttDealOffer *offer;
@property (nonatomic, strong) id<TaloolDealActionDelegate> delegate;
@property (nonatomic) CGFloat detailSize;

@end
