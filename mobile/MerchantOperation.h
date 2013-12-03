//
//  MerchantOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <TaloolOperation.h>
#import "TaloolProtocols.h"

@interface MerchantOperation : TaloolOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)delegate;

@property id<OperationQueueDelegate> delegate;

@end
