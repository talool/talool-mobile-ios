//
//  RegistrationOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AuthenticationOperation.h"

@interface RegistrationOperation : AuthenticationOperation

- (id) initWithUser:(NSString *)email
           password:(NSString *)password
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
                sex:(NSNumber *)sex
          birthDate:(NSDate *)birthDate
         facebookId:(NSString *)fbId
      facebookToken:(NSString *)fbToken
           delegate:(id<OperationQueueDelegate>)delegate;

@end
