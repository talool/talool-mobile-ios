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

- (id)initWithCard:(NSString *)cd
          expMonth:(NSString *)expM
           expYear:(NSString *)expY
      securityCode:(NSString *)sec
           zipCode:(NSString *)z
      venmoSession:(NSString *)s
             offer:(ttDealOffer *)offer
        fundraiser:(NSString *)fundraiser
          delegate:(id<OperationQueueDelegate>)d;

- (id)initWithPurchaseCode:(NSString *)code offer:(ttDealOffer *)offer fundraiser:(NSString *)fundraiser delegate:(id<OperationQueueDelegate>)d;

- (id)initWithActivationCode:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)d;
- (id)initWithTrackingCode:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)d;

@end
