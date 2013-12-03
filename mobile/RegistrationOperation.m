//
//  RegistrationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RegistrationOperation.h"
#import "Talool-API/ttCustomer.h"

@interface RegistrationOperation()

@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *password;
@property (nonatomic, readwrite, strong) NSString *lastName;
@property (nonatomic, readwrite, strong) NSString *firstName;
@property (strong, nonatomic) NSNumber *sex;
@property (nonatomic, readwrite, strong) NSDate *birthDate;

@end

@implementation RegistrationOperation

- (id) initWithUser:(NSString *)e
           password:(NSString *)p
          firstName:(NSString *)fName
           lastName:(NSString *)lName
                sex:(NSNumber *)s
          birthDate:(NSDate *)bDate
           delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.email = e;
        self.password = p;
        self.delegate = d;
        self.firstName = fName;
        self.lastName = lName;
        self.sex = s;
        self.birthDate = bDate;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        NSMutableDictionary *delegateResponse;
        
        NSError *error = nil;
        NSManagedObjectContext *context = [self getContext];
        ttCustomer *customer = [ttCustomer createCustomer:self.firstName
                                                 lastName:self.lastName
                                                    email:self.email
                                            socialAccount:nil
                                                  context:context];
        
        if ([self.sex intValue] > 0) {
            [customer setAsFemale:([self.sex intValue]==1)];
        }
        [customer setBirthDate:self.birthDate];
        
        BOOL result = [ttCustomer registerCustomer:customer password:self.password context:context error:&error];
        
        if (result)
        {
            delegateResponse = [self setUpUser:&error];
            result = [[delegateResponse objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
        }
        
        
        if (self.delegate)
        {
            if (!delegateResponse)
            {
                delegateResponse = [[NSMutableDictionary alloc] init];
            }
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(userAuthComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
        
    }
    
}
@end
