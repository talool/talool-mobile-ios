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
           isFemale:(BOOL)isFemale
          birthDate:(NSDate *)birthDate
           delegate:(id<OperationQueueDelegate>)delegate;

@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *password;
@property (nonatomic, readwrite, strong) NSString *lastName;
@property (nonatomic, readwrite, strong) NSString *firstName;
@property BOOL isFemale;
@property (nonatomic, readwrite, strong) NSDate *birthDate;

@end
