//
//  ActivityOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import <TaloolProtocols.h>
#import "OperationQueueManager.h"
@interface ActivityOperation : TaloolOperation
- (id)initWithDelegate:(id<OperationQueueDelegate>)delegate;
- (id)initWithActivityId:(NSString *)aId delegate:(id<OperationQueueDelegate>)delegate;
- (id)initForEmailOperation:(NSString *)aId delegate:(id<OperationQueueDelegate>)delegate;

@end
