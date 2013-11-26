//
//  AuthenticationOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolOperation.h"
#import <TaloolProtocols.h>

@interface AuthenticationOperation : TaloolOperation

- (BOOL) setUpUser:(NSError **)error;

@property id<OperationQueueDelegate> delegate;

enum {
    AuthenticationErrorCode_SETUP_FAILED = 60
};
typedef int AuthenticationErrorCode;

@end
