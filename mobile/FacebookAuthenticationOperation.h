//
//  FacebookAuthenticationOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AuthenticationOperation.h"
#import "FacebookSDK/FacebookSDK.h"
#import "TaloolProtocols.h"

@interface FacebookAuthenticationOperation : AuthenticationOperation

- (id) initWithUser:(NSDictionary<FBGraphUser> *)user delegate:(id<OperationQueueDelegate>)delegate;

@property (nonatomic, readwrite, strong) NSDictionary<FBGraphUser> *user;

@end
