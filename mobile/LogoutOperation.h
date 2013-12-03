//
//  LogoutOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolOperation.h"
#import "TaloolProtocols.h"

@interface LogoutOperation : TaloolOperation

- (id) initWithDelegate:(id<OperationQueueDelegate>)delegate;
@property id<OperationQueueDelegate> delegate;

@end
