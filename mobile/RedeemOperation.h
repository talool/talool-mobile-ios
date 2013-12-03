//
//  RedeemOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolOperation.h"
#import <TaloolProtocols.h>

@interface RedeemOperation : TaloolOperation

- (id)initWithDealAcquireId:(NSString *)dealAcquireId delegate:(id<OperationQueueDelegate>)delegate;

@property id<OperationQueueDelegate> delegate;
@property (strong, nonatomic) NSString *dealAcquireId;

@end
