//
//  DealLayoutState.h
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaloolProtocols.h"
#import "BarCodeCell.h"
#import "DealDetailCell.h"
#import "DoubleLogoCell.h"

#define ROW_HEIGHT_LOGO    70.0f
#define ROW_HEIGHT_HERO    160.0f

@class ttDealAcquire;

@interface DealLayoutState : NSObject<TaloolDealLayoutDelegate>

- (id) initWithDeal:(ttDealAcquire *)dealAcquire offer:(ttDealOffer *)dealOffer actionDelegate:(id<TaloolDealActionDelegate>)actionDelegate;

@property (nonatomic, strong) ttDealAcquire *deal;
@property (nonatomic, strong) ttDealOffer *offer;
@property (nonatomic, strong) id<TaloolDealActionDelegate> delegate;
@property (nonatomic) CGFloat detailSize;

@end
