//
//  DealOfferOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaloolProtocols.h"

@interface DealOfferOperation : NSOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)delegate;

@property id<OperationQueueDelegate> delegate;

@end
