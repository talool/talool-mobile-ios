//
//  DealOfferDealsOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolProtocols.h>

@class ttDealOffer;

@interface DealOfferDealsOperation : NSOperation

- (id)initWithOffer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)d;
@property (nonatomic, readwrite, strong) ttDealOffer *dealOffer;
@property id<OperationQueueDelegate> delegate;

@end
