//
//  DealOfferOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import "TaloolProtocols.h"

@class ttDealOffer;

@interface DealOfferOperation : TaloolOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)delegate;

- (id)initPurchase:(NSString *)nonce offer:(ttDealOffer *)offer fundraiser:(NSString *)fundraiser delegate:(id<OperationQueueDelegate>)d;

- (id)initWithCode:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)d;

- (id)initForClientToken:(id<OperationQueueDelegate>)d;

@end
