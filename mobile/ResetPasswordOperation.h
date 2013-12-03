//
//  ResetPasswordOperation.h
//  Talool
//
//  Created by Douglas McCuen on 12/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AuthenticationOperation.h"
#import <TaloolProtocols.h>

@interface ResetPasswordOperation : AuthenticationOperation

- (id) initWithPassword:(NSString *)pw customerId:(NSString *)cId changeToken:(NSString *)ct delegate:(id<OperationQueueDelegate>)delegate;

@property id<OperationQueueDelegate> delegate;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *customerId;
@property (strong, nonatomic) NSString *changeToken;

@end
