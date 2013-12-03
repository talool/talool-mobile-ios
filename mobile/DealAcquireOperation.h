//
//  DealAcquireOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import "TaloolProtocols.h"

@interface DealAcquireOperation : TaloolOperation

- (id)initWithMerchantId:(NSString *)merchantId delegate:(id<OperationQueueDelegate>)delegate;
@property (nonatomic, readwrite, strong) NSString *merchantId;
@property id<OperationQueueDelegate> delegate;

@end
