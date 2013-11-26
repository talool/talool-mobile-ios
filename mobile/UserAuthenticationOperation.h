//
//  UserAuthenticationOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AuthenticationOperation.h"

@interface UserAuthenticationOperation : AuthenticationOperation

- (id) initWithUser:(NSString *)email password:(NSString *)password delegate:(id<OperationQueueDelegate>)delegate;

@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *password;

@end
