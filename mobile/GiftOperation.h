//
//  GiftOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolOperation.h"
#import <TaloolProtocols.h>

@interface GiftOperation : TaloolOperation

- (id)initWithEmail:(NSString *)email dealAcquireId:(NSString *)dealAcquireId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)delegate;

- (id)initWithFacebookId:(NSString *)fbId dealAcquireId:(NSString *)dealAcquireId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)delegate;

- (id)initWithGiftId:(NSString *)gId delegate:(id<OperationQueueDelegate>)delegate;

- (id)initWithGiftId:(NSString *)gId activityId:(NSString *)aId accept:(BOOL)accept delegate:(id<OperationQueueDelegate>)delegate;

@end
